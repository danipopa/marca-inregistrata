class TrademarkRequest < ApplicationRecord
  CLASS_PRICE_LEI = 449
  BASE_PRICE_LEI = 2_226

  before_validation :set_defaults

  validates :mark, :email, :phone, presence: true
  validates :classes_count, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 11 }
  validates :total_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def total_lei
    total_cents.to_i / 100
  end

  private

  def set_defaults
    self.classes_count ||= 1
    self.currency = "RON"
    self.status ||= "new"
    self.total_cents = (BASE_PRICE_LEI + (classes_count.to_i - 1) * CLASS_PRICE_LEI) * 100
  end
end
