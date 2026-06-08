require "test_helper"

class Api::V1::PaymentVerificationsControllerTest < ActionDispatch::IntegrationTest
  test "marks Stripe order paid when checkout session is paid" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    order = trademark_request_for(user, payment_method: "card", payment_provider: "stripe")

    with_class_method(Payments::StripeCheckout, :paid?, true) do
      post verify_payment_path(order),
        headers: { "Authorization" => "Bearer #{user.issue_auth_token!}" },
        as: :json
    end

    assert_response :success
    assert_equal true, response.parsed_body["verified"]
    assert_equal "paid", order.reload.status
  end

  test "keeps Stripe order pending when checkout session is not paid" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    order = trademark_request_for(user, payment_method: "card", payment_provider: "stripe")

    with_class_method(Payments::StripeCheckout, :paid?, false) do
      post verify_payment_path(order),
        headers: { "Authorization" => "Bearer #{user.issue_auth_token!}" },
        as: :json
    end

    assert_response :success
    assert_equal false, response.parsed_body["verified"]
    assert_equal "pending_payment", order.reload.status
  end

  test "captures PayPal order and marks it paid" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    order = trademark_request_for(user, payment_method: "paypal", payment_provider: "paypal")

    with_class_method(Payments::PaypalCheckout, :capture!, true) do
      post verify_payment_path(order),
        headers: { "Authorization" => "Bearer #{user.issue_auth_token!}" },
        as: :json
    end

    assert_response :success
    assert_equal true, response.parsed_body["verified"]
    assert_equal "paid", order.reload.status
  end

  test "does not verify another user's order" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    other_user = User.create_with_password!(email: "other@example.com", password: "password123")
    order = trademark_request_for(other_user, payment_method: "card", payment_provider: "stripe")

    post verify_payment_path(order),
      headers: { "Authorization" => "Bearer #{user.issue_auth_token!}" },
      as: :json

    assert_response :not_found
    assert_equal "pending_payment", order.reload.status
  end

  private

  def verify_payment_path(order)
    "/api/v1/account/purchases/#{order.id}/verify_payment"
  end

  def with_class_method(klass, method_name, return_value)
    original = klass.method(method_name)
    klass.define_singleton_method(method_name) { |_order| return_value }
    yield
  ensure
    klass.define_singleton_method(method_name, original)
  end

  def trademark_request_for(user, payment_method:, payment_provider:)
    TrademarkRequest.create!(
      user: user,
      email: user.email,
      phone: "0712345678",
      owner_type: "Societate",
      tax_id: "RO12345678",
      owner_name: "Client SRL",
      address: "Strada Test 1",
      mark: "BRAND",
      product_code: "ro-word",
      classes_count: 1,
      primary_class: "Clasa 35",
      payment_method: payment_method,
      payment_provider: payment_provider,
      payment_provider_id: "provider-id-123"
    )
  end
end
