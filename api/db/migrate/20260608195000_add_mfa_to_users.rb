class AddMfaToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :otp_secret, :string
    add_column :users, :otp_enabled_at, :datetime
    add_column :users, :mfa_challenge_digest, :string
    add_column :users, :mfa_challenge_created_at, :datetime
    add_index :users, :mfa_challenge_digest, unique: true
  end
end
