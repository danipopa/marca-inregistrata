require_relative "../monitoring_test_helper"

class MonitoringNotificationJobTest < ActiveSupport::TestCase
  include MonitoringTestHelper
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  test "only reviewed relevant matches notify the customer and only once" do
    subscription = monitoring_order(status: "paid").monitoring_subscription
    with_provider(fake_provider(results: [ sample_match ])) { CheckTrademarkJob.perform_now(subscription.id) }
    match = subscription.monitoring_matches.first
    assert_no_emails { MonitoringNotificationJob.perform_now(match.id) }
    assert_enqueued_with(job: MonitoringNotificationJob, args: [ match.id ]) { match.update!(review_status: "relevant") }
    assert_emails(1) { MonitoringNotificationJob.perform_now(match.id) }
    assert_equal [ subscription.email ], ActionMailer::Base.deliveries.last.to
    assert_no_emails { MonitoringNotificationJob.perform_now(match.id) }
    assert match.reload.notified_at.present?
  end

  test "disabled notifications do not send alerts or reports" do
    subscription = monitoring_order(status: "paid").monitoring_subscription
    subscription.update!(notifications_enabled: false, next_report_at: 1.day.ago)
    with_provider(fake_provider(results: [ sample_match ])) do
      CheckTrademarkJob.perform_now(subscription.id)
      match = subscription.monitoring_matches.first
      match.update!(review_status: "relevant")
      assert_no_emails do
        MonitoringNotificationJob.perform_now(match.id)
        SendMonitoringReportsJob.perform_now
      end
    end
  end

  test "monthly reports require recorded checks and do not repeat in the same period" do
    subscription = monitoring_order(status: "paid").monitoring_subscription
    subscription.update!(next_report_at: 1.minute.ago)
    with_provider(fake_provider) do
      assert_no_emails { SendMonitoringReportsJob.perform_now }
      CheckTrademarkJob.perform_now(subscription.id)
      assert_emails(1) { SendMonitoringReportsJob.perform_now }
      assert_no_emails { SendMonitoringReportsJob.perform_now }
      assert subscription.reload.last_report_at.present?
    end
  end
end
