class AddUserToTrademarkRequests < ActiveRecord::Migration[8.1]
  def change
    add_reference :trademark_requests, :user, foreign_key: true
  end
end
