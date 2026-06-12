class AddMfaAttemptControlsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :mfa_failed_attempts, :integer, null: false, default: 0
    add_column :users, :mfa_locked_until, :datetime
  end
end
