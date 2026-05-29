class AddLogoImageToSiteThemes < ActiveRecord::Migration[8.1]
  def change
    add_column :site_themes, :logo_image_key, :string
  end
end
