require "test_helper"

class TrademarkRequestTest < ActiveSupport::TestCase
  test "computes total from selected class count" do
    request = TrademarkRequest.new(mark: "BRAND", email: "client@example.com", phone: "0712345678", classes_count: 3)

    assert request.valid?
    assert_equal 2734, request.total_lei
  end

  test "computes total from selected product" do
    request = TrademarkRequest.new(
      mark: "BRAND",
      email: "client@example.com",
      phone: "0712345678",
      product_code: "ro-color",
      classes_count: 2
    )

    assert request.valid?
    assert_equal "Marca color", request.product_name
    assert_equal 3394, request.total_lei
  end

  test "computes OSIM renewal total with class and owner change options" do
    request = TrademarkRequest.new(
      mark: "BRAND",
      email: "client@example.com",
      phone: "0712345678",
      product_code: "renew-ro-word",
      classes_count: 2,
      owner_change_requested: true
    )

    assert request.valid?
    assert_equal "renewal", request.order_type
    assert_equal "RON", request.currency
    assert_equal 2422, request.total_lei
    assert_equal "2.422 Lei", request.formatted_total
  end

  test "computes EUIPO renewal total with official extra class schedule" do
    request = TrademarkRequest.new(
      mark: "BRAND",
      email: "client@example.com",
      phone: "0712345678",
      product_code: "renew-eu-word",
      classes_count: 3,
      owner_change_requested: true
    )

    assert request.valid?
    assert_equal "renewal", request.order_type
    assert_equal false, request.owner_change_requested
    assert_equal "EUR", request.currency
    assert_equal 1200, request.total_lei
    assert_equal "1.200 EUR", request.formatted_total
  end

  test "computes EUIPO registration total with official extra class schedule" do
    request = TrademarkRequest.new(
      mark: "BRAND",
      email: "client@example.com",
      phone: "0712345678",
      product_code: "eu-word",
      classes_count: 3
    )

    assert request.valid?
    assert_equal "registration", request.order_type
    assert_equal "EUR", request.currency
    assert_equal 5623, request.total_lei
    assert_equal "5.623 EUR", request.formatted_total
  end

  test "computes monitoring order as fixed annual price" do
    request = TrademarkRequest.new(
      mark: "BRAND",
      email: "client@example.com",
      phone: "0712345678",
      product_code: "monitoring-brand",
      classes_count: 6
    )

    assert request.valid?
    assert_equal "monitoring", request.order_type
    assert_equal "RON", request.currency
    assert_equal 726, request.total_lei
    assert_equal "726 Lei", request.formatted_total
  end

  test "computes verification order as fixed price without class extras" do
    TrademarkProduct.create!(
      code: "verification-brand",
      currency: "RON",
      region: "OSIM / EUIPO",
      price_label: "300 Lei",
      base_price_lei: 300,
      title_ro: "Verificare marca",
      title_en: "Trademark check",
      position: 80
    )

    request = TrademarkRequest.new(
      mark: "BRAND",
      email: "client@example.com",
      phone: "0712345678",
      product_code: "verification-brand",
      classes_count: 6
    )

    assert request.valid?
    assert_equal "verification", request.order_type
    assert_equal "RON", request.currency
    assert_equal 300, request.total_lei
    assert_equal "300 Lei", request.formatted_total
  end
end
