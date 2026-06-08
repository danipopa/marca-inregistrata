class TrademarkRequest < ApplicationRecord
  OSIM_CLASS_PRICE = 254
  OSIM_RENEWAL_OWNER_CHANGE_PRICE = 477
  EUIPO_EXTRA_CLASS_TOTALS = {
    1 => 0,
    2 => 50,
    3 => 200,
    4 => 350,
    5 => 500,
    6 => 650,
    7 => 800,
    8 => 950,
    9 => 1_100,
    10 => 1_250,
    11 => 1_400
  }.freeze

  belongs_to :user, optional: true
  has_many :events, class_name: "TrademarkRequestEvent", dependent: :destroy

  before_validation :set_defaults

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

  def set_defaults
    self.classes_count ||= 1
    self.product_code = product_code.presence || "ro-word"
    product = TrademarkProduct.active.find_by(code: product_code)
    self.product_name = product.title_ro if product
    self.currency = product&.currency || "RON"
    self.order_type = order_type_for(product_code)
    self.owner_change_requested = false unless osim_renewal_product?(product_code)
    self.status = "pending_payment" if status.blank? || status == "new"
    self.admin_comments = "" if has_attribute?(:admin_comments) && admin_comments.blank?
    self.email = email.to_s.strip.downcase
    self.total_cents = total_units(product) * 100
  end

  def product_code_exists
    return if TrademarkProduct.active.exists?(code: product_code)

    errors.add(:product_code, "is not included in the list")
  end

  def total_units(product)
    base = product&.base_price_lei || 0
    base + extra_class_total(product) + owner_change_total(product)
  end

  def extra_class_total(product)
    count = classes_count.to_i.clamp(1, 11)

    if osim_product?(product&.code)
      (count - 1) * OSIM_CLASS_PRICE
    elsif euipo_product?(product&.code)
      EUIPO_EXTRA_CLASS_TOTALS.fetch(count, 0)
    elsif monitoring_product?(product&.code) || verification_product?(product&.code)
      0
    else
      0
    end
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
