class AddAdminCommentsToTrademarkRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :trademark_requests, :admin_comments, :text, null: false, default: ""
  end
end
