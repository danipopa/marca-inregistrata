class AddBillingProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :phone, :string
    add_column :users, :owner_type, :string
    add_column :users, :tax_id, :string
    add_column :users, :owner_name, :string
    add_column :users, :address, :text
  end
end
