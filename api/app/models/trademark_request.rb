class TrademarkRequest < ApplicationRecord
  CLASS_PRICE_LEI = 449
  PRODUCTS = {
    "ro-word" => { name: "Marca verbala", base_price_lei: 2_226 },
    "ro-monochrome" => { name: "Marca alb-negru", base_price_lei: 2_378 },
    "ro-color" => { name: "Marca color", base_price_lei: 3_140 },
    "eu-word" => { name: "Marca Uniunea Europeana", base_price_lei: 5_423 },
    "eu-logo" => { name: "Logo UE", base_price_lei: 3_085 }
  }.freeze

  belongs_to :user, optional: true

  before_validation :set_defaults

  validates :mark, :email, :phone, :product_code, :product_name, presence: true
  validates :product_code, inclusion: { in: PRODUCTS.keys }
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
    product = PRODUCTS[product_code]
    self.product_name = product[:name] if product
    self.currency = "RON"
    self.status = "pending_payment" if status.blank? || status == "new"
    self.email = email.to_s.strip.downcase
    self.total_cents = ((product&.fetch(:base_price_lei) || 0) + (classes_count.to_i - 1) * CLASS_PRICE_LEI) * 100
  end
end
