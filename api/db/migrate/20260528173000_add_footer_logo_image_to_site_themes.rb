class AddFooterLogoImageToSiteThemes < ActiveRecord::Migration[8.1]
  def change
    add_column :site_themes, :footer_logo_image_key, :string
  end
end
