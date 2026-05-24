require "test_helper"

class Api::V1::Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "requires login" do
    get api_v1_admin_dashboard_url, as: :json

    assert_response :unauthorized
  end

  test "requires an admin user" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")

    get api_v1_admin_dashboard_url,
      headers: { "Authorization" => "Bearer #{user.issue_auth_token!}" },
      as: :json

    assert_response :forbidden
  end

  test "shows admin dashboard data" do
    admin = User.create_with_password!(email: "admin@example.com", password: "password123")
    admin.update!(admin: true)

    TrademarkRequest.create!(
      mark: "BRAND",
      product_code: "ro-word",
      classes_count: 1,
      email: "client@example.com",
      phone: "0712345678",
      payment_method: "card"
    )

    get api_v1_admin_dashboard_url,
      headers: { "Authorization" => "Bearer #{admin.issue_auth_token!}" },
      as: :json

    assert_response :success
    assert_equal 1, response.parsed_body.dig("stats", "orders_count")
    assert_equal 1, response.parsed_body.dig("stats", "users_count")
    assert_equal "BRAND", response.parsed_body.dig("orders", 0, "mark")
    assert_equal "admin@example.com", response.parsed_body.dig("users", 0, "email")
  end
end
