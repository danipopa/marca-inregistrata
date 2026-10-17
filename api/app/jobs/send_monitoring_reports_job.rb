class SendMonitoringReportsJob < ApplicationJob
  queue_as :mailers
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform
    return unless TrademarkMonitoring::Provider.current.configured?

    MonitoringSubscription.active.where(notifications_enabled: true).where("next_report_at <= ?", Time.current).find_each do |subscription|
      subscription.with_lock do
        next unless subscription.active_now? && subscription.next_report_at <= Time.current
        since = subscription.last_report_at || subscription.activated_at
        next unless subscription.monitoring_checks.where(status: %w[succeeded failed]).where("finished_at > ?", since).exists?

        MonitoringMailer.monthly_report(subscription.id, since.iso8601).deliver_now
        subscription.update!(last_report_at: Time.current, next_report_at: 1.month.from_now)
      end
    end
  end
end
