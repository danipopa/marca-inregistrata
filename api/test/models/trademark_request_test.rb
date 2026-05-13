require "test_helper"

class TrademarkRequestTest < ActiveSupport::TestCase
  test "computes total from selected class count" do
    request = TrademarkRequest.new(mark: "BRAND", email: "client@example.com", phone: "0712345678", classes_count: 3)

    assert request.valid?
    assert_equal 3124, request.total_lei
  end
end
