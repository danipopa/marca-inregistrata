class AddRemovedFromAccountAtToTrademarkRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :trademark_requests, :removed_from_account_at, :datetime
    add_index :trademark_requests, :removed_from_account_at
  end
end
