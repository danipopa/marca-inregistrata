require "test_helper"

class Api::V1::AccountsControllerTest < ActionDispatch::IntegrationTest
  test "shows purchases for an email account" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    user.update!(
      phone: "0712345678",
      owner_type: "Societate",
      owner_name: "Client SRL",
      address: "Strada Test 1"
    )
    token = user.issue_auth_token!

    TrademarkRequest.create!(
      mark: "BRAND",
      product_code: "ro-word",
      classes_count: 1,
      email: "client@example.com",
      phone: "0712345678",
      payment_method: "card"
    )

    get api_v1_account_url, headers: { "Authorization" => "Bearer #{token}" }, as: :json

    assert_response :success
    assert_equal "client@example.com", response.parsed_body.dig("account", "email")
    assert_equal true, response.parsed_body.dig("account", "billing_profile", "complete")
    assert_equal 1, response.parsed_body.dig("account", "purchases_count")
    assert_equal "Marca verbala", response.parsed_body.dig("account", "purchases", 0, "product_name")
  end

  test "updates billing profile" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    token = user.issue_auth_token!

    patch api_v1_account_url,
      params: {
        account: {
          phone: "0712345678",
          owner_type: "Societate",
          tax_id: "RO12345678",
          owner_name: "Client SRL",
          address: "Strada Test 1"
        }
      },
      headers: { "Authorization" => "Bearer #{token}" },
      as: :json

    assert_response :success
    assert_equal true, response.parsed_body.dig("account", "billing_profile", "complete")
    assert_equal true, response.parsed_body.dig("user", "billing_complete")
    assert_equal "Client SRL", user.reload.owner_name
  end

  test "requires login" do
    get api_v1_account_url, as: :json

    assert_response :unauthorized
  end
end
