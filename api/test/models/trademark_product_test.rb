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
  test "class prices override totals while blank counts retain the legacy calculation" do
    product = trademark_products(:ro_word)
    base = product.base_price_lei
    product.update!(class_prices: { "2" => 3000, "3" => 0 })
    assert_equal base, product.price_for_classes(1)
    assert_equal 3000, product.price_for_classes(2)
    assert_equal 0, product.price_for_classes(3)
    assert_equal base + 3 * 254, product.price_for_classes(4)
    assert_equal "OSIM", product.office
    product.update!(class_prices: {})
    assert_equal base + 254, product.price_for_classes(2)
  end

  test "rejects invalid class-price counts amounts and non-class services" do
    product = trademark_products(:ro_word)
    [ { "1" => 100 }, { "12" => 100 }, { "two" => 100 }, { "2" => -1 }, { "2" => 1.5 }, { "2" => "100" }, [] ].each do |prices|
      product.class_prices = prices
      assert_not product.valid?, prices.inspect
      assert product.errors[:class_prices].present?
    end
    product = trademark_products(:monitoring_brand)
    product.class_prices = { "2" => 100 }
    assert_not product.valid?
  end

  test "catalog exposes effective defaults and office derived from the product code" do
    product = trademark_products(:eu_word)
    product.update!(region: "OSIM", class_prices: { "3" => 1234 })
    payload = product.as_catalog_json
    assert_equal "EUIPO", payload[:office]
    assert_equal 1234, payload[:class_prices]["3"]
    assert_equal 50, payload[:class_surcharges]["2"]
    assert_equal 200, payload[:class_surcharges]["3"]
    assert payload[:supports_class_pricing]
  end
end
