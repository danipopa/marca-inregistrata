class TrademarkProduct < ApplicationRecord
  MAX_CLASSES = 11
  OSIM_CLASS_PRICE = 254
  EUIPO_CLASS_SURCHARGES = { 1 => 0, 2 => 50, 3 => 200, 4 => 350, 5 => 500, 6 => 650, 7 => 800, 8 => 950, 9 => 1_100, 10 => 1_250, 11 => 1_400 }.freeze

  attribute :class_prices, :json, default: -> { {} }

  before_validation :set_default_items

  validates :code, :currency, :region, :price_label, :title_ro, :title_en, presence: true
  validates :code, uniqueness: true
  validates :base_price_lei, :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :valid_class_prices

  def office
    return "OSIM" if code.to_s.start_with?("ro-", "renew-ro-")
    return "EUIPO" if code.to_s.start_with?("eu-", "renew-eu-")
    { "RO" => "OSIM", "EU" => "EUIPO" }.fetch(region.to_s.strip.upcase, region.to_s.strip.upcase)
  end

  def supports_class_pricing?
    !code.to_s.start_with?("monitoring-", "verification-")
  end

  def class_surcharge(count)
    return 0 unless supports_class_pricing?
    count = count.to_i.clamp(1, MAX_CLASSES)
    return (count - 1) * OSIM_CLASS_PRICE if code.to_s.start_with?("ro-", "renew-ro-")
    return EUIPO_CLASS_SURCHARGES.fetch(count) if code.to_s.start_with?("eu-", "renew-eu-")
    0
  end

  def price_for_classes(count)
    count = count.to_i.clamp(1, MAX_CLASSES)
    if supports_class_pricing? && count > 1 && class_prices.is_a?(Hash) && class_prices.key?(count.to_s)
      return class_prices.fetch(count.to_s)
    end
    base_price_lei + class_surcharge(count)
  end

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :id) }

  def items_ro_list
    parse_items(items_ro)
  end

  def items_en_list
    parse_items(items_en)
  end

  def items_ro_list=(items)
    self.items_ro = normalize_items(items).to_json
  end

  def items_en_list=(items)
    self.items_en = normalize_items(items).to_json
  end

  def as_catalog_json(image_url: nil)
    payload = {
      id: id,
      code: code,
      currency: currency,
      region: region,
      price: price_label,
      base_lei: base_price_lei,
      office: office,
      supports_class_pricing: supports_class_pricing?,
      class_prices: class_prices || {},
      class_surcharges: (1..MAX_CLASSES).to_h { |count| [ count.to_s, class_surcharge(count) ] },
      image_key: image_key,
      active: active?,
      position: position,
      translations: {
        ro: {
          title: title_ro,
          note: note_ro,
          tax: tax_ro,
          items: items_ro_list
        },
        en: {
          title: title_en,
          note: note_en,
          tax: tax_en,
          items: items_en_list
        }
      }
    }

    payload[:image] = image_url if image_url.present?
    payload
  end

  private

  def valid_class_prices
    unless class_prices.is_a?(Hash)
      errors.add(:class_prices, "must be a mapping of class counts to total prices")
      return
    end
    if class_prices.present? && !supports_class_pricing?
      errors.add(:class_prices, "are only available for registration and renewal products")
    end
    class_prices.each do |count, price|
      unless count.to_s.match?(/\A(?:[2-9]|10|11)\z/)
        errors.add(:class_prices, "must use class counts between 2 and 11; use the base price for one class")
      end
      unless price.is_a?(Integer) && price >= 0
        errors.add(:class_prices, "must contain non-negative whole currency amounts")
      end
    end
  end

  def set_default_items
    self.class_prices = {} if class_prices.nil?
    self.class_prices = class_prices.stringify_keys if class_prices.is_a?(Hash)
    self.items_ro = "[]" if items_ro.blank?
    self.items_en = "[]" if items_en.blank?
  end

  def parse_items(value)
    JSON.parse(value.presence || "[]")
  rescue JSON::ParserError
    []
  end

  def normalize_items(items)
    Array(items).flat_map { |item| item.to_s.split("\n") }.map(&:strip).reject(&:blank?)
  end
end
