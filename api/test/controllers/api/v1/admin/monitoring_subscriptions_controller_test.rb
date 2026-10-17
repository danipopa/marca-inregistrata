require_relative "../../../../monitoring_test_helper"

class Api::V1::Admin::MonitoringSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  include MonitoringTestHelper

  test "customers cannot access admin monitoring controls" do
    order = monitoring_order
    get "/api/v1/admin/monitoring_subscriptions", headers: { "Authorization" => "Bearer #{issue_mfa_auth_token(order.user)}" }
    assert_response :forbidden
  end

  test "admin can approve pause inspect and cancel a subscription without enabling the provider" do
    subscription = monitoring_order.monitoring_subscription
    admin = User.create_with_password!(email: "monitoring-admin@example.com", password: "password123")
    admin.update!(admin: true)
    headers = { "Authorization" => "Bearer #{issue_mfa_auth_token(admin)}" }
    patch "/api/v1/admin/monitoring_subscriptions/#{subscription.id}", params: { monitoring_subscription: { status: "active", interval_hours: 12 } }, headers: headers, as: :json
    assert_response :success
    assert_equal "awaiting_api_configuration", response.parsed_body.dig("subscription", "display_status")
    assert_equal 12, subscription.reload.interval_hours
    assert subscription.expires_at.present?
    post "/api/v1/admin/monitoring_subscriptions/#{subscription.id}/check", headers: headers, as: :json
    assert_response :unprocessable_entity
    patch "/api/v1/admin/monitoring_subscriptions/#{subscription.id}", params: { monitoring_subscription: { status: "paused" } }, headers: headers, as: :json
    assert_response :success
    assert_equal "paused", subscription.reload.status
    get "/api/v1/admin/monitoring_subscriptions/#{subscription.id}", headers: headers
    assert_response :success
    assert_equal [], response.parsed_body["checks"]
    patch "/api/v1/admin/monitoring_subscriptions/#{subscription.id}", params: { monitoring_subscription: { status: "cancelled" } }, headers: headers, as: :json
    assert_response :success
    assert_equal "cancelled", subscription.reload.status
    patch "/api/v1/admin/monitoring_subscriptions/#{subscription.id}", params: { monitoring_subscription: { status: "paused" } }, headers: headers, as: :json
    assert_response :unprocessable_entity
    assert_equal "cancelled", subscription.reload.status
  end
end
