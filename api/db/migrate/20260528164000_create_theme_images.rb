class CreateThemeImages < ActiveRecord::Migration[8.1]
  def change
    create_table :theme_images do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :theme_images, :name
  end
end
