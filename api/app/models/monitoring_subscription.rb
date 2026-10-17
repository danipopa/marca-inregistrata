class MonitoringSubscription < ApplicationRecord
  OFFICES = %w[OSIM EUIPO WIPO].freeze
  STATUSES = %w[pending_activation active paused cancelled expired].freeze
  PAID_STATUSES = %w[paid processing completed].freeze

  belongs_to :trademark_request
  has_many :monitoring_checks, dependent: :destroy
  has_many :monitoring_matches, dependent: :destroy
  delegate :mark, :email, :user, to: :trademark_request
  before_validation do
    self.registration_number = registration_number.to_s.strip.presence
    self.registration_office = registration_office.to_s.strip.upcase.presence
  end

  validates :status, inclusion: { in: STATUSES }
  validates :registration_office, inclusion: { in: OFFICES }, allow_blank: true
  validates :registration_number, length: { maximum: 255 }
  validates :interval_hours, numericality: { only_integer: true, greater_than_or_equal_to: 6, less_than_or_equal_to: 720 }
  validates :registration_number, :registration_office, :activated_at, :expires_at, presence: true, if: -> { status == "active" }

  scope :active, -> { where(status: "active").where("expires_at > ?", Time.current) }
  scope :due, -> { active.where("next_check_at IS NULL OR next_check_at <= ?", Time.current) }

  def self.sync_for_order!(order)
    return unless order.order_type == "monitoring"

    subscription = find_or_create_by!(trademark_request: order) do |record|
      record.registration_number = order.registration_number
      record.registration_office = order.registration_office
    end
    if %w[cancelled refunded].include?(order.status)
      subscription.update!(status: "cancelled", next_check_at: nil)
    elsif PAID_STATUSES.include?(order.status) && subscription.status == "pending_activation" && subscription.identification_complete?
      subscription.activate!(only_if_pending: true)
    end
    subscription
  end

  def identification_complete?
    registration_number.present? && OFFICES.include?(registration_office)
  end

  def active_now?
    status == "active" && expires_at.present? && expires_at > Time.current
  end

  def activate!(only_if_pending: false)
    with_lock do
      return if only_if_pending && status != "pending_activation"
      unless identification_complete?
        errors.add(:base, "Registration number and office are required")
        raise ActiveRecord::RecordInvalid, self
      end
      if %w[cancelled expired].include?(status)
        errors.add(:base, "A cancelled or expired subscription cannot be reactivated")
        raise ActiveRecord::RecordInvalid, self
      end
      if expires_at.present? && expires_at <= Time.current
        errors.add(:base, "Monitoring has expired; a new monitoring order is required")
        raise ActiveRecord::RecordInvalid, self
      end
      update!(status: "active", activated_at: activated_at || Time.current,
        expires_at: expires_at || 1.year.from_now, next_check_at: next_check_at || Time.current,
        next_report_at: next_report_at || 1.month.from_now)
    end
  end

  def display_status
    return "expired" if status == "active" && !active_now?
    return "awaiting_api_configuration" if active_now? && !TrademarkMonitoring::Provider.current.configured?

    status
  end
end
