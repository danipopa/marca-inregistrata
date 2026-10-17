class TrafficRequestMetric < ApplicationRecord
  def self.record!(endpoint:, status:, duration_ms:)
    bucket = create_or_find_by!(hour: Time.current.beginning_of_hour, endpoint: endpoint, status: status)
    # Atomic increments avoid losing simultaneous requests from different Puma workers.
    where(id: bucket.id).update_all([
      "requests_count = requests_count + 1, duration_ms_total = duration_ms_total + ?, duration_ms_max = CASE WHEN duration_ms_max < ? THEN ? ELSE duration_ms_max END",
      duration_ms, duration_ms, duration_ms
    ])
  end
end
