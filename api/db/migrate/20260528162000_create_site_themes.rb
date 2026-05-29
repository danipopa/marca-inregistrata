class CreateSiteThemes < ActiveRecord::Migration[8.1]
  def change
    create_table :site_themes do |t|
      t.string :primary_color, null: false, default: "#00add9"
      t.string :primary_dark_color, null: false, default: "#00add9"
      t.string :brand_color, null: false, default: "#013ebe"
      t.string :text_color, null: false, default: "#1f1d1a"
      t.string :muted_color, null: false, default: "#68635c"
      t.string :line_color, null: false, default: "#ded8cf"
      t.string :background_color, null: false, default: "#ffffff"
      t.string :font_family, null: false, default: "Montserrat"

      t.timestamps
    end
  end
end
