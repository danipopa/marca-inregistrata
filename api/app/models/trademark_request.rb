class TrademarkRequest < ApplicationRecord
  OSIM_CLASS_PRICE = TrademarkProduct::OSIM_CLASS_PRICE
  OSIM_RENEWAL_OWNER_CHANGE_PRICE = 477
  EUIPO_EXTRA_CLASS_TOTALS = TrademarkProduct::EUIPO_CLASS_SURCHARGES

  belongs_to :user, optional: true
  has_many :events, class_name: "TrademarkRequestEvent", dependent: :destroy
  has_one :monitoring_subscription, dependent: :destroy

  before_validation :set_defaults
  after_save_commit :sync_monitoring_subscription, if: -> { order_type == "monitoring" }
  validates :registration_number, presence: true, on: :create, if: -> { order_type == "monitoring" }
  validates :registration_number, length: { maximum: 255 }
  validates :registration_office, inclusion: { in: MonitoringSubscription::OFFICES }, on: :create, if: -> { order_type == "monitoring" }

  validates :mark, :email, :phone, :product_code, :product_name, presence: true
  validate :product_code_exists
  validates :order_type, inclusion: { in: %w[registration renewal monitoring verification] }
  validates :payment_method, inclusion: { in: %w[card paypal transfer], allow_blank: true }
  validates :classes_count, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 11 }
  validates :total_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def total_lei
    total_cents.to_i / 100
  end

  def formatted_total
    suffix = currency == "EUR" ? "EUR" : "Lei"
    "#{total_lei.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse} #{suffix}"
  end

  private

  def sync_monitoring_subscription
    MonitoringSubscription.sync_for_order!(self)
  end

  def set_defaults
    self.registration_number = registration_number.to_s.strip.presence
    self.registration_office = registration_office.to_s.strip.upcase.presence
    self.classes_count ||= 1
    self.product_code = product_code.presence || "ro-word"
    product = TrademarkProduct.active.find_by(code: product_code)
    reprice = new_record? || will_save_change_to_product_code? || will_save_change_to_classes_count? || will_save_change_to_owner_change_requested?
    self.product_name = product.title_ro if product && reprice
    self.currency = product&.currency || "RON" if reprice
    self.order_type = order_type_for(product_code)
    self.owner_change_requested = false unless osim_renewal_product?(product_code)
    self.status = "pending_payment" if status.blank? || status == "new"
    self.admin_comments = "" if has_attribute?(:admin_comments) && admin_comments.blank?
    self.email = email.to_s.strip.downcase
    self.total_cents = total_units(product) * 100 if reprice
  end

  def product_code_exists
    return if TrademarkProduct.active.exists?(code: product_code)

    errors.add(:product_code, "is not included in the list")
  end

  def total_units(product)
    (product&.price_for_classes(classes_count) || 0) + owner_change_total(product)
  end

  def order_type_for(code)
    return "monitoring" if monitoring_product?(code)
    return "verification" if verification_product?(code)
    return "renewal" if renewal_product?(code)

    "registration"
  end

  def owner_change_total(product)
    return 0 unless owner_change_requested? && osim_renewal_product?(product&.code)

    OSIM_RENEWAL_OWNER_CHANGE_PRICE
  end

  def renewal_product?(code)
    code.to_s.start_with?("renew-")
  end

  def osim_renewal_product?(code)
    code.to_s.start_with?("renew-ro-")
  end

  def euipo_renewal_product?(code)
    code.to_s.start_with?("renew-eu-")
  end

  def osim_product?(code)
    code.to_s.start_with?("ro-", "renew-ro-")
  end

  def euipo_product?(code)
    code.to_s.start_with?("eu-", "renew-eu-")
  end

  def monitoring_product?(code)
    code.to_s.start_with?("monitoring-")
  end

  def verification_product?(code)
    code.to_s.start_with?("verification-")
  end
end
