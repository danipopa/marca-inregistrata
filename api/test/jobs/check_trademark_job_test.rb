require_relative "../monitoring_test_helper"

class CheckTrademarkJobTest < ActiveSupport::TestCase
  include MonitoringTestHelper
  include ActiveJob::TestHelper

  test "missing provider records blocked rather than successful without making a search" do
    subscription = monitoring_order(status: "paid").monitoring_subscription
    with_provider(TrademarkMonitoring::Provider.new) { CheckTrademarkJob.perform_now(subscription.id) }
    assert_equal "blocked", subscription.monitoring_checks.last.status
    assert_nil subscription.reload.last_success_at
    assert_equal 0, subscription.monitoring_matches.count
  end

  test "scheduler skips unconfigured and unpaid subscriptions" do
    subscription = monitoring_order.monitoring_subscription
    with_provider(TrademarkMonitoring::Provider.new) do
      assert_no_enqueued_jobs(only: CheckTrademarkJob) { ScheduleMonitoringChecksJob.perform_now }
    end
    with_provider(fake_provider) do
      assert_no_enqueued_jobs(only: CheckTrademarkJob) { ScheduleMonitoringChecksJob.perform_now }
      subscription.activate!
      assert_enqueued_with(job: CheckTrademarkJob, args: [ subscription.id ]) { ScheduleMonitoringChecksJob.perform_now }
    end
  end

  test "a successful complete result set is deduplicated across repeated checks" do
    subscription = monitoring_order(status: "paid").monitoring_subscription
    with_provider(fake_provider(results: [ sample_match ])) do
      assert_no_enqueued_jobs(only: MonitoringNotificationJob) { CheckTrademarkJob.perform_now(subscription.id) }
      assert_equal 1, subscription.monitoring_matches.count
      assert_equal 1, subscription.monitoring_checks.last.new_matches_count
      subscription.update!(next_check_at: 1.minute.ago)
      CheckTrademarkJob.perform_now(subscription.id)
      assert_equal 1, subscription.monitoring_matches.count
      assert_equal 0, subscription.monitoring_checks.last.new_matches_count
      assert_equal "succeeded", subscription.monitoring_checks.last.status
      assert subscription.reload.last_success_at.present?
      assert_in_delta 24.hours.from_now.to_i, subscription.next_check_at.to_i, 2
    end
  end

  test "duplicate queued jobs and a held lease do not issue duplicate checks" do
    subscription = monitoring_order(status: "paid").monitoring_subscription
    subscription.update!(lease_token: "another-worker", lease_expires_at: 5.minutes.from_now)
    with_provider(fake_provider) do
      CheckTrademarkJob.perform_now(subscription.id)
      assert_equal 0, subscription.monitoring_checks.count
      subscription.update!(lease_token: nil, lease_expires_at: nil)
      CheckTrademarkJob.perform_now(subscription.id)
      CheckTrademarkJob.perform_now(subscription.id)
      assert_equal 1, subscription.monitoring_checks.count
    end
  end

  test "rate limits schedule a retry and never mark a check successful" do
    subscription = monitoring_order(status: "paid").monitoring_subscription
    error = TrademarkMonitoring::Provider::RateLimited.new(retry_after: 2.hours)
    with_provider(fake_provider(error: error)) { CheckTrademarkJob.perform_now(subscription.id) }
    assert_equal "failed", subscription.monitoring_checks.last.status
    assert_nil subscription.reload.last_success_at
    assert_nil subscription.lease_token
    assert_in_delta 2.hours.from_now.to_i, subscription.next_check_at.to_i, 2
  end

  test "malformed results fail atomically instead of producing a partial successful check" do
    subscription = monitoring_order(status: "paid").monitoring_subscription
    with_provider(fake_provider(results: [ sample_match, { name: "Missing identifier" } ])) do
      CheckTrademarkJob.perform_now(subscription.id)
    end
    assert_equal 0, subscription.monitoring_matches.count
    assert_equal "failed", subscription.monitoring_checks.last.status
  end

  test "pausing while provider request runs cancels its results" do
    subscription = monitoring_order(status: "paid").monitoring_subscription
    provider = fake_provider
    provider.define_singleton_method(:search) do |subscription:|
      subscription.update!(status: "paused")
      [ { id: "1", name: "OTHER", office: "OSIM" } ]
    end
    with_provider(provider) { CheckTrademarkJob.perform_now(subscription.id) }
    assert_equal "cancelled", subscription.monitoring_checks.last.status
    assert_equal 0, subscription.monitoring_matches.count
  end

  test "expired subscriptions are not checked" do
    subscription = monitoring_order(status: "paid").monitoring_subscription
    subscription.update!(expires_at: 1.day.ago)
    with_provider(fake_provider) { CheckTrademarkJob.perform_now(subscription.id) }
    assert_equal 0, subscription.monitoring_checks.count
  end
end
