class AddMfaRecoveryCodesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :recovery_codes_digest, :text
  end
end
