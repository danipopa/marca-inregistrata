class AddClassPricesToTrademarkProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :trademark_products, :class_prices, :json
  end
end
