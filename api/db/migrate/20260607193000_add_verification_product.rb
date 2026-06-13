class AddVerificationProduct < ActiveRecord::Migration[8.1]
  def up
    now = Time.current
    product = create_insertable_model.find_or_initialize_by(code: "verification-brand")
    product.assign_attributes(
      currency: "RON",
      region: "OSIM / EUIPO",
      price_label: "0 Lei",
      base_price_lei: 0,
      title_ro: "Verificare marca",
      title_en: "Trademark check",
      note_ro: "analiza preliminara disponibilitate marca",
      note_en: "preliminary trademark availability check",
      tax_ro: "pret editabil din admin",
      tax_en: "price editable from admin",
      items_ro: [
        "verificare denumire propusa",
        "analiza clase NISA indicate",
        "recomandare inainte de depunere"
      ].to_json,
      items_en: [
        "proposed name check",
        "review of selected NICE classes",
        "recommendation before filing"
      ].to_json,
      image_key: nil,
      position: 80,
      active: true,
      created_at: product.created_at || now,
      updated_at: now
    )
    product.save!
  end

  def down
    create_insertable_model.where(code: "verification-brand").delete_all
  end

  private

  def create_insertable_model
    Class.new(ApplicationRecord) do
      self.table_name = "trademark_products"
    end
  end
end
