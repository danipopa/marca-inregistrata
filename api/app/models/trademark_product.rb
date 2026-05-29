class TrademarkProduct < ApplicationRecord
  before_validation :set_default_items

  validates :code, :currency, :region, :price_label, :title_ro, :title_en, presence: true
  validates :code, uniqueness: true
  validates :base_price_lei, :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

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

  def set_default_items
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
