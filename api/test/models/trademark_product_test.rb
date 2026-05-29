require "test_helper"

class TrademarkProductTest < ActiveSupport::TestCase
  test "defaults item lists to empty arrays before saving" do
    product = TrademarkProduct.new(
      code: "test-product",
      currency: "RON",
      region: "OSIM",
      price_label: "100 Lei",
      title_ro: "Produs test",
      title_en: "Test product"
    )

    assert product.valid?
    assert_equal [], product.items_ro_list
    assert_equal [], product.items_en_list
    assert_equal "[]", product.items_ro
    assert_equal "[]", product.items_en
  end
end
