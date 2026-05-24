class AddProductFieldsToTrademarkRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :trademark_requests, :product_code, :string, null: false, default: "ro-word"
    add_column :trademark_requests, :product_name, :string, null: false, default: "Marca verbala"

    add_index :trademark_requests, :product_code
    add_index :trademark_requests, :created_at
  end
end
