class CheckTrademarkJob < ApplicationJob
  queue_as :monitoring

  def perform(subscription_id)
    subscription = MonitoringSubscription.find_by(id: subscription_id)
    return unless subscription

    provider = TrademarkMonitoring::Provider.current
    token = SecureRandom.uuid
    check = claim(subscription, provider, token)
    return unless check

    unless provider.configured?
      finish_failure(subscription, check, token, "Awaiting API configuration", status: "blocked")
      return
    end

    results = provider.search(subscription: subscription)
    validate_results!(results)
    subscription.with_lock do
      return unless subscription.lease_token == token
      unless subscription.active_now?
        check.update!(status: "cancelled", finished_at: Time.current)
        subscription.update!(lease_token: nil, lease_expires_at: nil)
        return
      end

      new_matches = 0
      results.each do |record|
        identity = Digest::SHA256.hexdigest([ provider.name, record.fetch(:office), record.fetch(:id) ].join("\0"))
        match = subscription.monitoring_matches.find_or_initialize_by(identity_key: identity)
        new_matches += 1 if match.new_record?
        source_url = record[:source_url].to_s
        source_url = nil unless source_url.match?(%r{\Ahttps?://}i)
        match.update!(external_id: record.fetch(:id), office: record.fetch(:office), name: record.fetch(:name),
          trademark_status: record[:status], application_number: record[:application_number],
          registration_number: record[:registration_number], source_url: source_url,
          first_seen_at: match.first_seen_at || Time.current, last_seen_at: Time.current)
      end
      check.update!(status: "succeeded", results_count: results.length, new_matches_count: new_matches, finished_at: Time.current)
      subscription.update!(last_checked_at: Time.current, last_success_at: Time.current,
        next_check_at: subscription.interval_hours.hours.from_now, consecutive_failures: 0,
        last_error: nil, lease_token: nil, lease_expires_at: nil)
    end
  rescue StandardError => error
    if check && subscription
      delay = error.is_a?(TrademarkMonitoring::Provider::RateLimited) ? error.retry_after : nil
      finish_failure(subscription, check, token, "Check failed (#{error.class.name})", retry_after: delay)
    end
    raise unless error.is_a?(TrademarkMonitoring::Provider::Error)
  end

  private

  def claim(subscription, provider, token)
    subscription.with_lock do
      return unless subscription.active_now?
      return if subscription.next_check_at.present? && subscription.next_check_at > Time.current
      return if subscription.lease_expires_at.present? && subscription.lease_expires_at > Time.current

      subscription.monitoring_checks.where(status: "running").update_all(status: "failed", error_message: "Previous worker lease expired", finished_at: Time.current)
      subscription.update!(lease_token: token, lease_expires_at: 15.minutes.from_now)
      subscription.monitoring_checks.create!(provider: provider.name, started_at: Time.current)
    end
  end

  def validate_results!(results)
    valid = results.is_a?(Array) && results.all? do |record|
      record.is_a?(Hash) && %i[id office name].all? { |key| record[key].is_a?(String) && record[key].present? && record[key].length <= 255 }
    end
    raise TrademarkMonitoring::Provider::InvalidResponse, "Provider returned an invalid result set" unless valid
  end

  def finish_failure(subscription, check, token, message, status: "failed", retry_after: nil)
    subscription.with_lock do
      return unless subscription.lease_token == token

      failures = subscription.consecutive_failures + 1
      delay = retry_after || [ 5.minutes * (2**[ failures - 1, 7 ].min), 6.hours ].min
      check.update!(status: status, error_message: message, finished_at: Time.current)
      subscription.update!(last_checked_at: Time.current, last_error: message, consecutive_failures: failures,
        next_check_at: Time.current + delay, lease_token: nil, lease_expires_at: nil)
    end
  end
end
