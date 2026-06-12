require "test_helper"

class Api::V1::Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "requires login" do
    get api_v1_admin_dashboard_url, as: :json

    assert_response :unauthorized
  end

  test "requires an admin user" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")

    get api_v1_admin_dashboard_url,
      headers: { "Authorization" => "Bearer #{issue_mfa_auth_token(user)}" },
      as: :json

    assert_response :forbidden
  end

  test "shows admin dashboard data" do
    admin = User.create_with_password!(email: "admin@example.com", password: "password123")
    admin.update!(admin: true)

    order = TrademarkRequest.create!(
      mark: "BRAND",
      product_code: "ro-word",
      classes_count: 1,
      email: "client@example.com",
      phone: "0712345678",
      payment_method: "card",
      ip_address: "203.0.113.20",
      admin_comments: "Call after payment"
    )

    get api_v1_admin_dashboard_url,
      headers: { "Authorization" => "Bearer #{issue_mfa_auth_token(admin)}" },
      as: :json

    assert_response :success
    assert_equal 1, response.parsed_body.dig("stats", "orders_count")
    assert_equal 1, response.parsed_body.dig("stats", "users_count")
    assert_equal "BRAND", response.parsed_body.dig("orders", 0, "mark")
    assert_equal order.created_at.iso8601, response.parsed_body.dig("orders", 0, "created_at")
    assert_equal "203.0.113.20", response.parsed_body.dig("orders", 0, "ip_address")
    assert_equal "Call after payment", response.parsed_body.dig("orders", 0, "admin_comments")
    assert_equal [], response.parsed_body.dig("orders", 0, "events")
    assert_equal "admin@example.com", response.parsed_body.dig("users", 0, "email")
  end

  test "updates order admin comments" do
    admin = User.create_with_password!(email: "admin@example.com", password: "password123")
    admin.update!(admin: true)
    order = TrademarkRequest.create!(
      mark: "BRAND",
      product_code: "ro-word",
      classes_count: 1,
      email: "client@example.com",
      phone: "0712345678",
      payment_method: "card"
    )

    patch api_v1_admin_trademark_request_url(order),
      params: {
        trademark_request: {
          admin_comments: "Client asked for invoice details."
        }
      },
      headers: { "Authorization" => "Bearer #{issue_mfa_auth_token(admin)}" },
      as: :json

    assert_response :success
    assert_equal "Client asked for invoice details.", order.reload.admin_comments
    assert_equal "Client asked for invoice details.", response.parsed_body.dig("order", "admin_comments")
    assert_equal 1, order.events.count
    assert_equal "admin_comments_changed", order.events.last.action
    assert_equal "admin@example.com", response.parsed_body.dig("order", "events", 0, "admin_email")
  end

  test "marks bank transfer order as paid" do
    admin = User.create_with_password!(email: "admin@example.com", password: "password123")
    admin.update!(admin: true)
    order = TrademarkRequest.create!(
      mark: "BRAND",
      product_code: "ro-word",
      classes_count: 1,
      email: "client@example.com",
      phone: "0712345678",
      payment_method: "transfer"
    )

    patch api_v1_admin_trademark_request_url(order),
      params: {
        trademark_request: {
          status: "paid"
        }
      },
      headers: { "Authorization" => "Bearer #{issue_mfa_auth_token(admin)}" },
      as: :json

    assert_response :success
    assert_equal "paid", order.reload.status
    assert_equal "paid", response.parsed_body.dig("order", "status")
    assert_equal 1, order.events.count
    assert_equal "status_changed", order.events.last.action
    assert_equal "pending_payment", order.events.last.old_value
    assert_equal "paid", order.events.last.new_value
  end
end
