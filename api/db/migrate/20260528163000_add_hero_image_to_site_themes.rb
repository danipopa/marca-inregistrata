class AddHeroImageToSiteThemes < ActiveRecord::Migration[8.1]
  def change
    add_column :site_themes, :hero_image_key, :string
  end
end
