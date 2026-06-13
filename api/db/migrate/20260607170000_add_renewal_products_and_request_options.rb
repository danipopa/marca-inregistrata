class AddRenewalProductsAndRequestOptions < ActiveRecord::Migration[8.1]
  def up
    add_column :trademark_requests, :order_type, :string, null: false, default: "registration" unless column_exists?(:trademark_requests, :order_type)
    add_column :trademark_requests, :owner_change_requested, :boolean, null: false, default: false unless column_exists?(:trademark_requests, :owner_change_requested)

    now = Time.current
    products = renewal_products.map do |product|
      product.merge(
        items_ro: product[:items_ro].to_json,
        items_en: product[:items_en].to_json,
        created_at: now,
        updated_at: now
      )
    end

    create_insertable_model.upsert_all(products, unique_by: :code)
  end

  def down
    create_insertable_model.where(code: renewal_product_codes).delete_all
    remove_column :trademark_requests, :owner_change_requested if column_exists?(:trademark_requests, :owner_change_requested)
    remove_column :trademark_requests, :order_type if column_exists?(:trademark_requests, :order_type)
  end

  private

  def renewal_product_codes
    [
      "renew-ro-word",
      "renew-ro-monochrome",
      "renew-ro-color",
      "renew-eu-word",
      "renew-eu-monochrome",
      "renew-eu-color"
    ]
  end

  def renewal_products
    [
      {
        code: "renew-ro-word",
        currency: "RON",
        region: "OSIM",
        price_label: "1.691 Lei",
        base_price_lei: 1_691,
        title_ro: "Reinnoire marca verbala OSIM",
        title_en: "OSIM word trademark renewal",
        note_ro: "prelungire protectie pentru 10 ani",
        note_en: "10-year protection renewal",
        tax_ro: "991 Lei taxe + 700 Lei onorariu",
        tax_en: "991 Lei fees + 700 Lei legal fee",
        items_ro: [
          "include taxa introducere mandatar",
          "include taxa eliberare certificat reinnoire",
          "o clasa NISA inclusa"
        ],
        items_en: [
          "representative filing fee included",
          "renewal certificate fee included",
          "one NICE class included"
        ],
        image_key: "verbal",
        position: 101
      },
      {
        code: "renew-ro-monochrome",
        currency: "RON",
        region: "OSIM",
        price_label: "1.843 Lei",
        base_price_lei: 1_843,
        title_ro: "Reinnoire marca alb-negru OSIM",
        title_en: "OSIM black-and-white trademark renewal",
        note_ro: "prelungire protectie pentru 10 ani",
        note_en: "10-year protection renewal",
        tax_ro: "1.143 Lei taxe + 700 Lei onorariu",
        tax_en: "1,143 Lei fees + 700 Lei legal fee",
        items_ro: [
          "include taxa introducere mandatar",
          "include taxa eliberare certificat reinnoire",
          "o clasa NISA inclusa"
        ],
        items_en: [
          "representative filing fee included",
          "renewal certificate fee included",
          "one NICE class included"
        ],
        image_key: "black_white",
        position: 102
      },
      {
        code: "renew-ro-color",
        currency: "RON",
        region: "OSIM",
        price_label: "2.249 Lei",
        base_price_lei: 2_249,
        title_ro: "Reinnoire marca color OSIM",
        title_en: "OSIM color trademark renewal",
        note_ro: "prelungire protectie pentru 10 ani",
        note_en: "10-year protection renewal",
        tax_ro: "1.549 Lei taxe + 700 Lei onorariu",
        tax_en: "1,549 Lei fees + 700 Lei legal fee",
        items_ro: [
          "include taxa introducere mandatar",
          "include taxa eliberare certificat reinnoire",
          "o clasa NISA inclusa"
        ],
        items_en: [
          "representative filing fee included",
          "renewal certificate fee included",
          "one NICE class included"
        ],
        image_key: "color",
        position: 103
      },
      {
        code: "renew-eu-word",
        currency: "EUR",
        region: "EUIPO",
        price_label: "1.000 EUR",
        base_price_lei: 1_000,
        title_ro: "Reinnoire marca verbala EUIPO",
        title_en: "EUIPO word trademark renewal",
        note_ro: "prelungire protectie la nivel european",
        note_en: "EU-wide protection renewal",
        tax_ro: "850 EUR taxe + 150 EUR onorariu",
        tax_en: "850 EUR fees + 150 EUR legal fee",
        items_ro: ["o clasa NISA inclusa", "valabilitate reinnoita pentru 10 ani"],
        items_en: ["one NICE class included", "renewed validity for 10 years"],
        image_key: "verbal",
        position: 104
      },
      {
        code: "renew-eu-monochrome",
        currency: "EUR",
        region: "EUIPO",
        price_label: "1.000 EUR",
        base_price_lei: 1_000,
        title_ro: "Reinnoire marca alb-negru EUIPO",
        title_en: "EUIPO black-and-white trademark renewal",
        note_ro: "prelungire protectie la nivel european",
        note_en: "EU-wide protection renewal",
        tax_ro: "850 EUR taxe + 150 EUR onorariu",
        tax_en: "850 EUR fees + 150 EUR legal fee",
        items_ro: ["o clasa NISA inclusa", "valabilitate reinnoita pentru 10 ani"],
        items_en: ["one NICE class included", "renewed validity for 10 years"],
        image_key: "black_white",
        position: 105
      },
      {
        code: "renew-eu-color",
        currency: "EUR",
        region: "EUIPO",
        price_label: "1.000 EUR",
        base_price_lei: 1_000,
        title_ro: "Reinnoire marca color EUIPO",
        title_en: "EUIPO color trademark renewal",
        note_ro: "prelungire protectie la nivel european",
        note_en: "EU-wide protection renewal",
        tax_ro: "850 EUR taxe + 150 EUR onorariu",
        tax_en: "850 EUR fees + 150 EUR legal fee",
        items_ro: ["o clasa NISA inclusa", "valabilitate reinnoita pentru 10 ani"],
        items_en: ["one NICE class included", "renewed validity for 10 years"],
        image_key: "color",
        position: 106
      }
    ]
  end

  def create_insertable_model
    Class.new(ApplicationRecord) do
      self.table_name = "trademark_products"
    end
  end
end
