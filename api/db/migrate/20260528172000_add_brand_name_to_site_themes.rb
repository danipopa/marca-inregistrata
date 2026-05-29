class AddBrandNameToSiteThemes < ActiveRecord::Migration[8.1]
  DEFAULT_BRAND_NAME = "SANDU și Asociații IP Attorney".freeze

  def change
    add_column :site_themes, :brand_name, :string, null: false, default: DEFAULT_BRAND_NAME
  end
end
