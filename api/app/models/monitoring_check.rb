class MonitoringCheck < ApplicationRecord
  belongs_to :monitoring_subscription
  validates :status, inclusion: { in: %w[running succeeded failed blocked cancelled] }
end
