require "test_helper"

class TrademarkRequestTest < ActiveSupport::TestCase
  test "computes total from selected class count" do
    request = TrademarkRequest.new(mark: "BRAND", email: "client@example.com", phone: "0712345678", classes_count: 3)

    assert request.valid?
    assert_equal 3124, request.total_lei
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
    assert_equal 3589, request.total_lei
  end
end
