require_relative "../../../monitoring_test_helper"

class Api::V1::MonitoringOrdersFlowTest < ActionDispatch::IntegrationTest
  include MonitoringTestHelper
  include ActiveJob::TestHelper

  test "checkout stores monitoring identification and creates an awaiting activation subscription" do
    user = User.create_with_password!(email: "checkout-monitoring@example.com", password: "password123")
    user.update!(phone: "0712345678", owner_type: "Societate", tax_id: "RO12345678", owner_name: "Client SRL", address: "Test 1")
    headers = { "Authorization" => "Bearer #{issue_mfa_auth_token(user)}" }
    assert_difference("MonitoringSubscription.count", 1) do
      post "/api/v1/trademark_requests", params: { trademark_request: {
        product_code: "monitoring-brand", mark: "EXAMPLE", classes: 1,
        registration_number: "001234", registration_office: "EUIPO", goods: "Notes",
        payment: "transfer", terms: true
      } }, headers: headers, as: :json
      assert_response :created
    end
    order = TrademarkRequest.find(response.parsed_body["id"])
    assert_equal "001234", order.monitoring_subscription.registration_number
    assert_equal "EUIPO", order.monitoring_subscription.registration_office
    assert_equal user, order.monitoring_subscription.user
    assert_equal "pending_activation", order.monitoring_subscription.status
    get "/api/v1/account", headers: headers
    assert_response :success
    assert_equal "pending_activation", response.parsed_body.dig("account", "purchases", 0, "monitoring", "status")
  end

  test "verified Stripe payment activates monitoring and an unverified payment does not" do
    order = monitoring_order(payment_method: "card", payment_provider: "stripe", payment_provider_id: "test-session")
    headers = { "Authorization" => "Bearer #{issue_mfa_auth_token(order.user)}" }
    original = Payments::StripeCheckout.method(:paid?)
    Payments::StripeCheckout.define_singleton_method(:paid?) { |_record| false }
    post "/api/v1/account/purchases/#{order.id}/verify_payment", headers: headers, as: :json
    assert_response :success
    assert_equal "pending_activation", order.monitoring_subscription.reload.status
    Payments::StripeCheckout.define_singleton_method(:paid?) { |_record| true }
    post "/api/v1/account/purchases/#{order.id}/verify_payment", headers: headers, as: :json
    assert_response :success
    assert_equal "active", order.monitoring_subscription.reload.status
    payload = response.parsed_body
    assert_equal true, payload["verified"]
    assert_equal order.id, payload.dig("order", "id")
    assert_equal order.product_code, payload.dig("order", "product", "code")
    assert_equal order.total_lei, payload.dig("order", "total", "amount")
    assert_equal order.currency, payload.dig("order", "total", "currency")
    assert_not payload["order"].key?("mark")
    assert_not payload["order"].key?("email")
  ensure
    Payments::StripeCheckout.define_singleton_method(:paid?, original) if original
  end

  test "customers cannot review results and provider cooldown cannot be bypassed manually" do
    order = monitoring_order(status: "paid")
    subscription = order.monitoring_subscription
    with_provider(fake_provider(results: [ sample_match ])) { CheckTrademarkJob.perform_now(subscription.id) }
    match = subscription.monitoring_matches.first
    customer_headers = { "Authorization" => "Bearer #{issue_mfa_auth_token(order.user)}" }
    patch "/api/v1/admin/monitoring_matches/#{match.id}", params: { monitoring_match: { review_status: "relevant" } }, headers: customer_headers, as: :json
    assert_response :forbidden
    assert_equal "pending", match.reload.review_status

    admin = User.create_with_password!(email: "reviewer@example.com", password: "password123")
    admin.update!(admin: true)
    admin_headers = { "Authorization" => "Bearer #{issue_mfa_auth_token(admin)}" }
    assert_enqueued_with(job: MonitoringNotificationJob, args: [ match.id ]) do
      patch "/api/v1/admin/monitoring_matches/#{match.id}", params: { monitoring_match: { review_status: "relevant" } }, headers: admin_headers, as: :json
      assert_response :success
    end
    assert_equal "monitoring_match_reviewed", order.events.last.action
    subscription.update!(last_error: "Rate limited", next_check_at: 2.hours.from_now)
    with_provider(fake_provider) do
      post "/api/v1/admin/monitoring_subscriptions/#{subscription.id}/check", headers: admin_headers, as: :json
      assert_response :too_many_requests
    end
  end
end
