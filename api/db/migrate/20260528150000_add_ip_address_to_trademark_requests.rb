class AddIpAddressToTrademarkRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :trademark_requests, :ip_address, :string
    add_index :trademark_requests, :ip_address
  end
end
