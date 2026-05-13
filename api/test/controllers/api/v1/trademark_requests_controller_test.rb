require "test_helper"

class Api::V1::TrademarkRequestsControllerTest < ActionDispatch::IntegrationTest
  test "creates a trademark request" do
    assert_difference("TrademarkRequest.count", 1) do
      post api_v1_trademark_requests_url,
        params: {
          trademark_request: {
            mark: "BRAND",
            classes: 2,
            primary_class: "Clasa 35",
            email: "client@example.com",
            phone: "0712345678",
            payment: "card",
            terms: true
          }
        },
        as: :json
    end

    assert_response :created
    assert_equal "new", response.parsed_body["status"]
  end
end
