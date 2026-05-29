class TrademarkRequest < ApplicationRecord
  CLASS_PRICE_LEI = 449

  belongs_to :user, optional: true

  before_validation :set_defaults

  validates :mark, :email, :phone, :product_code, :product_name, presence: true
  validate :product_code_exists
  validates :payment_method, inclusion: { in: %w[card paypal transfer], allow_blank: true }
  validates :classes_count, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 11 }
  validates :total_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def total_lei
    total_cents.to_i / 100
  end

  def formatted_total
    "#{total_lei.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse} Lei"
  end

  private

  def set_defaults
    self.classes_count ||= 1
    self.product_code = product_code.presence || "ro-word"
    product = TrademarkProduct.active.find_by(code: product_code)
    self.product_name = product.title_ro if product
    self.currency = product&.currency || "RON"
    self.status = "pending_payment" if status.blank? || status == "new"
    self.admin_comments = "" if has_attribute?(:admin_comments) && admin_comments.blank?
    self.email = email.to_s.strip.downcase
    self.total_cents = ((product&.base_price_lei || 0) + (classes_count.to_i - 1) * CLASS_PRICE_LEI) * 100
  end

  def product_code_exists
    return if TrademarkProduct.active.exists?(code: product_code)

    errors.add(:product_code, "is not included in the list")
  end
end
