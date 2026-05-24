class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :password_salt, null: false
      t.string :auth_token_digest
      t.datetime :auth_token_created_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :auth_token_digest, unique: true
  end
end
