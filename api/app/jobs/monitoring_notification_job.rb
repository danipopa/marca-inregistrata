class MonitoringNotificationJob < ApplicationJob
  queue_as :mailers
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(match_id)
    match = MonitoringMatch.find_by(id: match_id)
    return unless match

    match.with_lock do
      subscription = match.monitoring_subscription
      return unless match.review_status == "relevant" && match.notified_at.nil?
      return unless subscription.active_now? && subscription.notifications_enabled?

      MonitoringMailer.match_alert(match.id).deliver_now
      match.update!(notified_at: Time.current)
    end
  end
end
