require_relative "../monitoring_test_helper"

class MonitoringSubscriptionTest < ActiveSupport::TestCase
  include MonitoringTestHelper

  test "a monitoring order creates one pending subscription with structured identification" do
    assert_difference("MonitoringSubscription.count", 1) do
      order = monitoring_order
      assert_equal "pending_activation", order.monitoring_subscription.status
      assert_equal "000123", order.monitoring_subscription.registration_number
      order.update!(admin_comments: "Reviewed")
    end
  end

  test "payment activates once and repeated updates do not extend the term or resume a pause" do
    order = monitoring_order
    order.update!(status: "paid")
    subscription = order.monitoring_subscription.reload
    assert_equal "active", subscription.status
    assert_in_delta 1.year.from_now.to_i, subscription.expires_at.to_i, 2
    expires_at = subscription.expires_at
    subscription.update!(status: "paused")
    subscription.activate!(only_if_pending: true)
    assert_equal "paused", subscription.reload.status
    order.update!(status: "processing")
    assert_equal "paused", subscription.reload.status
    assert_equal expires_at, subscription.expires_at
    subscription.activate!
    assert_equal expires_at, subscription.reload.expires_at
  end

  test "an active entitlement without provider is awaiting configuration" do
    subscription = monitoring_order(status: "paid").monitoring_subscription
    with_provider(TrademarkMonitoring::Provider.new) do
      assert_equal "awaiting_api_configuration", subscription.display_status
    end
    assert_equal 0, subscription.monitoring_checks.count
  end

  test "admin activation requires identification and cannot revive cancelled or expired subscriptions" do
    subscription = monitoring_order.monitoring_subscription
    subscription.update!(registration_number: nil)
    assert_raises(ActiveRecord::RecordInvalid) { subscription.activate! }
    subscription.reload.update!(registration_number: "123", status: "cancelled")
    assert_raises(ActiveRecord::RecordInvalid) { subscription.activate! }
    subscription.reload.update!(status: "expired", expires_at: 1.day.ago)
    assert_raises(ActiveRecord::RecordInvalid) { subscription.activate! }
  end

  test "refunding a paid order stops its subscription" do
    order = monitoring_order(status: "paid")
    order.update!(status: "refunded")
    assert_equal "cancelled", order.monitoring_subscription.reload.status
  end

  test "reactivation does not bypass an existing provider cooldown" do
    subscription = monitoring_order(status: "paid").monitoring_subscription
    next_check = 2.hours.from_now
    subscription.update!(status: "paused", next_check_at: next_check, last_error: "Rate limited")
    subscription.activate!
    assert_in_delta next_check.to_i, subscription.reload.next_check_at.to_i, 1
  end

  test "monitoring cannot be ordered without registration number and office" do
    order = monitoring_order
    invalid = order.dup
    invalid.registration_number = nil
    invalid.registration_office = "OTHER"
    assert_not invalid.valid?
    assert invalid.errors[:registration_number].present?
    assert invalid.errors[:registration_office].present?
  end
end
