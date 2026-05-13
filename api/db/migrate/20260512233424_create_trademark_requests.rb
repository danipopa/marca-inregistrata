class CreateTrademarkRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :trademark_requests do |t|
      t.string :mark, null: false
      t.integer :classes_count, null: false, default: 1
      t.string :primary_class
      t.text :goods
      t.string :email, null: false
      t.string :phone, null: false
      t.string :owner_type
      t.string :tax_id
      t.string :owner_name
      t.text :address
      t.string :payment_method
      t.integer :total_cents, null: false, default: 0
      t.string :currency, null: false, default: "RON"
      t.string :status, null: false, default: "new"

      t.timestamps
    end

    add_index :trademark_requests, :email
    add_index :trademark_requests, :status
  end
end
