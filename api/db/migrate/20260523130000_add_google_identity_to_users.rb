class AddGoogleIdentityToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :google_sub, :string
    add_column :users, :name, :string
    add_index :users, :google_sub, unique: true
  end
end
