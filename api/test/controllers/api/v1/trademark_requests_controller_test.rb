require "test_helper"

class Api::V1::TrademarkRequestsControllerTest < ActionDispatch::IntegrationTest
  test "creates a trademark request" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    user.update!(
      phone: "0712345678",
      owner_type: "Societate",
      tax_id: "RO12345678",
      owner_name: "Client SRL",
      address: "Strada Test 1"
    )
    token = user.issue_auth_token!

    assert_difference("TrademarkRequest.count", 1) do
      assert_emails 1 do
        post api_v1_trademark_requests_url,
          params: {
            trademark_request: {
              mark: "BRAND",
              product_code: "ro-color",
              classes: 2,
              primary_class: "Clasa 35",
              payment: "transfer",
              terms: true
            }
          },
          headers: {
            "Authorization" => "Bearer #{token}",
            "REMOTE_ADDR" => "203.0.113.10"
          },
          as: :json
      end
    end

    assert_response :created
    email = ActionMailer::Base.deliveries.last
    assert_equal [ "contact@inregistrare-marca.com" ], email.to
    assert_equal [ "client@example.com" ], email.reply_to
    assert_includes email.subject, "Comanda noua"
    assert_includes email.text_part.body.to_s, "BRAND"
    assert_includes email.text_part.body.to_s, "203.0.113.10"
    assert_equal "pending_payment", response.parsed_body["status"]
    assert_equal "Marca color", response.parsed_body.dig("product", "name")
    assert_equal "client@example.com", TrademarkRequest.last.email
    assert_equal "203.0.113.10", TrademarkRequest.last.ip_address
    assert_equal "Client SRL", TrademarkRequest.last.owner_name
    assert_equal user, TrademarkRequest.last.user
  end

  test "requires completed account billing profile" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    token = user.issue_auth_token!

    assert_no_difference("TrademarkRequest.count") do
      post api_v1_trademark_requests_url,
        params: {
          trademark_request: {
            mark: "BRAND",
            product_code: "ro-color",
            classes: 2,
            primary_class: "Clasa 35",
            payment: "transfer",
            terms: true
          }
        },
        headers: { "Authorization" => "Bearer #{token}" },
        as: :json
    end

    assert_response :unprocessable_entity
    assert_equal "Completeaza datele de contact si facturare in cont inainte de checkout.", response.parsed_body["message"]
  end
end
