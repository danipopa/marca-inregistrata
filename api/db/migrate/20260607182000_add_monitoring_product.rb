class AddMonitoringProduct < ActiveRecord::Migration[8.1]
  def change
    reversible do |direction|
      direction.up do
        now = Time.current
        product = create_insertable_model.find_or_initialize_by(code: "monitoring-brand")
        product.assign_attributes(
          currency: "RON",
          region: "OSIM / EUIPO / WIPO",
          price_label: "726 Lei / an",
          base_price_lei: 726,
          title_ro: "Monitorizare marca",
          title_en: "Trademark monitoring",
          note_ro: "serviciu anual pentru o marca monitorizata",
          note_en: "annual service for one monitored trademark",
          tax_ro: "TVA inclus",
          tax_en: "VAT included",
          items_ro: [
            "identificare marci identice sau similare",
            "monitorizare OSIM, EUIPO si WIPO",
            "raportare lunara pe email",
            "propuneri de solutii juridice"
          ].to_json,
          items_en: [
            "identical or similar trademark identification",
            "OSIM, EUIPO and WIPO monitoring",
            "monthly email reporting",
            "legal solution proposals"
          ].to_json,
          image_key: "verbal",
          active: true,
          position: 120,
          created_at: product.created_at || now,
          updated_at: now
        )
        product.save!
      end

      direction.down do
        create_insertable_model.where(code: "monitoring-brand").delete_all
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
