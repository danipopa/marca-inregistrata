class AddPaymentProviderFieldsToTrademarkRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :trademark_requests, :payment_provider, :string
    add_column :trademark_requests, :payment_provider_id, :string
    add_column :trademark_requests, :payment_checkout_url, :text

    add_index :trademark_requests, :payment_provider
    add_index :trademark_requests, :payment_provider_id
  end
end
