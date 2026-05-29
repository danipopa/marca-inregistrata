class CreateTrademarkProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :trademark_products do |t|
      t.string :code, null: false
      t.string :currency, null: false, default: "RON"
      t.string :region, null: false, default: "OSIM"
      t.string :price_label, null: false
      t.integer :base_price_lei, null: false, default: 0
      t.string :title_ro, null: false
      t.string :title_en, null: false
      t.string :note_ro, null: false, default: ""
      t.string :note_en, null: false, default: ""
      t.string :tax_ro, null: false, default: "include TVA"
      t.string :tax_en, null: false, default: "includes VAT"
      t.text :items_ro, null: false, default: "[]"
      t.text :items_en, null: false, default: "[]"
      t.string :image_key
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :trademark_products, :code, unique: true
    add_index :trademark_products, %i[active position]

    reversible do |direction|
      direction.up do
        products = [
          {
            code: "ro-word",
            currency: "RON",
            region: "OSIM",
            price_label: "2.226 Lei",
            base_price_lei: 2_226,
            title_ro: "Marca verbala OSIM",
            title_en: "Word trademark",
            note_ro: "doar litere si cifre, fara logo",
            note_en: "letters and numbers only, without logo",
            tax_ro: "include TVA",
            tax_en: "includes VAT",
            items_ro: ["onorariu inclus: 1.210 Lei", "taxe OSIM incluse: 1.016 Lei", "o clasa NISA inclusa", "plata online securizata"],
            items_en: ["legal fee included: 1,210 Lei", "OSIM taxes included: 1,016 Lei", "one NICE class included", "secure online payment"],
            image_key: "verbal",
            position: 1
          },
          {
            code: "ro-monochrome",
            currency: "RON",
            region: "OSIM",
            price_label: "2.378 Lei",
            base_price_lei: 2_378,
            title_ro: "Marca alb-negru",
            title_en: "Black-and-white trademark",
            note_ro: "scriere speciala sau logo monocrom",
            note_en: "special lettering or monochrome logo",
            tax_ro: "include TVA",
            tax_en: "includes VAT",
            items_ro: ["onorariu inclus: 1.210 Lei", "taxe OSIM incluse: 1.168 Lei", "detaliere produse si servicii", "o clasa NISA inclusa"],
            items_en: ["legal fee included: 1,210 Lei", "OSIM taxes included: 1,168 Lei", "goods and services details", "one NICE class included"],
            image_key: "black_white",
            position: 2
          },
          {
            code: "ro-color",
            currency: "RON",
            region: "OSIM",
            price_label: "3.140 Lei",
            base_price_lei: 3_140,
            title_ro: "Marca color",
            title_en: "Color trademark",
            note_ro: "logo, design sau scriere color",
            note_en: "logo, design or colored lettering",
            tax_ro: "include TVA",
            tax_en: "includes VAT",
            items_ro: ["onorariu inclus: 1.210 Lei", "taxe OSIM incluse: 1.930 Lei", "upload fisier logo", "o clasa NISA inclusa"],
            items_en: ["legal fee included: 1,210 Lei", "OSIM taxes included: 1,930 Lei", "logo file upload", "one NICE class included"],
            image_key: "color",
            position: 3
          },
          {
            code: "eu-word",
            currency: "EUR",
            region: "EUIPO",
            price_label: "1.090 EUR",
            base_price_lei: 5_423,
            title_ro: "Marca Uniunea Europeana",
            title_en: "European Union trademark",
            note_ro: "protectie in statele membre UE",
            note_en: "protection in EU member states",
            tax_ro: "include TVA",
            tax_en: "includes VAT",
            items_ro: ["onorariu inclus: 240 EUR", "taxe EUIPO incluse: 850 EUR", "o clasa NISA inclusa", "depunere asistata online"],
            items_en: ["legal fee included: 240 EUR", "EUIPO taxes included: 850 EUR", "one NICE class included", "assisted online filing"],
            position: 4
          },
          {
            code: "eu-logo",
            currency: "EUR",
            region: "EUIPO",
            price_label: "620 EUR",
            base_price_lei: 3_085,
            title_ro: "Logo UE",
            title_en: "EU logo",
            note_ro: "semn figurativ sau mixt",
            note_en: "figurative or mixed sign",
            tax_ro: "include TVA",
            tax_en: "includes VAT",
            items_ro: ["onorariu inclus: 240 EUR", "taxe oficiale incluse: 380 EUR", "detaliere clase NISA", "procesare securizata"],
            items_en: ["legal fee included: 240 EUR", "official taxes included: 380 EUR", "NICE class details", "secure processing"],
            position: 5
          }
        ]

        now = Time.current
        products.each do |product|
          product[:items_ro] = product[:items_ro].to_json
          product[:items_en] = product[:items_en].to_json
          product[:image_key] = nil unless product.key?(:image_key)
          product[:created_at] = now
          product[:updated_at] = now
        end

        create_insertable_model.insert_all(products)
      end
    end
  end

  private

  def create_insertable_model
    Class.new(ApplicationRecord) do
      self.table_name = "trademark_products"
    end
  end
end
