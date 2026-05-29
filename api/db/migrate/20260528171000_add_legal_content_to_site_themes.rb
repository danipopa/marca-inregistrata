class AddLegalContentToSiteThemes < ActiveRecord::Migration[8.1]
  def change
    add_column :site_themes, :terms_content, :text
    add_column :site_themes, :privacy_policy_content, :text
  end
end
