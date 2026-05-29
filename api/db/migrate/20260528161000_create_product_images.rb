class CreateProductImages < ActiveRecord::Migration[8.1]
  def change
    create_table :product_images do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :product_images, :name
  end
end
