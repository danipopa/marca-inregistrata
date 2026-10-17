class ScheduleMonitoringChecksJob < ApplicationJob
  queue_as :monitoring

  def perform
    TrademarkRequest.where(order_type: "monitoring").where.missing(:monitoring_subscription).find_each do |order|
      MonitoringSubscription.sync_for_order!(order)
    end
    MonitoringSubscription.where(status: "active").where("expires_at <= ?", Time.current).update_all(status: "expired", next_check_at: nil)
    return unless TrademarkMonitoring::Provider.current.configured?

    MonitoringSubscription.due.find_each do |subscription|
      next if subscription.lease_expires_at.present? && subscription.lease_expires_at > Time.current

      CheckTrademarkJob.perform_later(subscription.id)
    end
  end
end
