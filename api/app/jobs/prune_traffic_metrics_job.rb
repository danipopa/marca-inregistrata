class PruneTrafficMetricsJob < ApplicationJob
  queue_as :default

  def perform
    TrafficPageView.where(created_at: ...90.days.ago.beginning_of_day).in_batches.delete_all
    TrafficRequestMetric.where(hour: ...90.days.ago.beginning_of_day).in_batches.delete_all
  end
end
