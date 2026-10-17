class MonitoringMatch < ApplicationRecord
  belongs_to :monitoring_subscription
  validates :identity_key, :external_id, :name, :office, :first_seen_at, :last_seen_at, presence: true
  validates :identity_key, uniqueness: { scope: :monitoring_subscription_id }
  validates :review_status, inclusion: { in: %w[pending relevant dismissed] }

  after_update_commit :notify_customer, if: -> { saved_change_to_review_status? && review_status == "relevant" }

  private

  def notify_customer
    MonitoringNotificationJob.perform_later(id) if notified_at.nil?
  end
end
