require "test_helper"

class Api::V1::TrafficTest < ActionDispatch::IntegrationTest
  setup do
    @consent = CookieConsent.create!(consent_id: "analytics-consent-test", version: TrafficPageView::CONSENT_VERSION, accepted: true, accepted_at: Time.current)
    @input = { page_view: { consent_id: @consent.consent_id, session_id: "session-1234567890", path: "/", referrer: "https://google.com/search?q=private#secret" } }
  end

  test "tracking requires current affirmative consent and only permits known public paths" do
    @consent.update!(accepted: false)
    assert_no_difference("TrafficPageView.count") { post "/api/v1/traffic_page_views", params: @input, as: :json }
    assert_response :forbidden
    @consent.update!(accepted: true, version: "old-policy")
    post "/api/v1/traffic_page_views", params: @input, as: :json
    assert_response :forbidden
    @consent.update!(version: TrafficPageView::CONSENT_VERSION)
    @input[:page_view][:path] = "/password-reset?token=secret"
    post "/api/v1/traffic_page_views", params: @input, as: :json
    assert_response :unprocessable_entity
    @input[:page_view][:path] = "/admin"
    post "/api/v1/traffic_page_views", params: @input, as: :json
    assert_response :unprocessable_entity
  end

  test "page tracking stores hashed identities and only referring hostname" do
    assert_difference("TrafficPageView.count", 1) { post "/api/v1/traffic_page_views", params: @input, as: :json }
    assert_response :no_content
    view = TrafficPageView.order(:id).last
    assert_equal "google.com", view.referrer_host
    assert_equal 64, view.visitor_key.length
    assert_not_equal @consent.consent_id, view.visitor_key
    assert_equal TrafficPageView.anonymous_key(@consent.consent_id), view.visitor_key
    assert_not view.attributes.values.join.include?("private")
    assert_not view.attributes.values.join.include?("session-1234567890")
    @input[:page_view][:referrer] = "javascript:alert(1)"
    post "/api/v1/traffic_page_views", params: @input, as: :json
    assert_nil TrafficPageView.order(:id).last.referrer_host
  end

  test "bots and excessive events do not create page views" do
    assert_no_difference("TrafficPageView.count") do
      post "/api/v1/traffic_page_views", params: @input, headers: { "User-Agent" => "Googlebot" }, as: :json
    end
    120.times { TrafficPageView.create!(visitor_key: TrafficPageView.anonymous_key(@consent.consent_id), session_key: "s" * 64, path: "/") }
    assert_no_difference("TrafficPageView.count") { post "/api/v1/traffic_page_views", params: @input, as: :json }
    assert_response :too_many_requests
  end

  test "admin reporting is protected and correctly counts unique visitors sessions and daily views" do
    get "/api/v1/admin/traffic"
    assert_response :unauthorized
    user = User.create_with_password!(email: "traffic-reader@example.com", password: "password123")
    headers = { "Authorization" => "Bearer #{issue_mfa_auth_token(user)}" }
    get "/api/v1/admin/traffic", headers: headers
    assert_response :forbidden
    user.update!(admin: true)
    2.times { post "/api/v1/traffic_page_views", params: @input, as: :json }
    @input[:page_view][:session_id] = "session-9876543210"
    post "/api/v1/traffic_page_views", params: @input, as: :json
    TrafficPageView.create!(visitor_key: "v" * 64, session_key: "s" * 64, path: "/order", created_at: 91.days.ago)
    TrafficRequestMetric.record!(endpoint: "GET test#index", status: 200, duration_ms: 10)
    TrafficRequestMetric.record!(endpoint: "GET test#index", status: 500, duration_ms: 30)
    get "/api/v1/admin/traffic?days=7", headers: headers
    assert_response :success
    report = response.parsed_body
    assert_equal 1, report["visitors"]
    assert_equal 2, report["sessions"]
    assert_equal 3, report["page_views"]
    assert_equal 7, report["daily"].size
    assert_equal 3, report["daily"].sum { |day| day["views"] }
    assert_equal 2, report.dig("technical", "requests")
    assert_equal 1, report.dig("technical", "server_errors")
    assert_equal 20, report.dig("technical", "average_ms")
    assert_equal 30, report.dig("technical", "max_ms")
  end

  test "retention removes old data and preserves current records" do
    old = TrafficPageView.create!(visitor_key: "v" * 64, session_key: "s" * 64, path: "/", created_at: 91.days.ago)
    post "/api/v1/traffic_page_views", params: @input, as: :json
    current = TrafficPageView.order(:id).last
    old_metric = TrafficRequestMetric.create!(hour: 91.days.ago, endpoint: "GET old", status: 200)
    TrafficRequestMetric.record!(endpoint: "GET current", status: 200, duration_ms: 12)
    PruneTrafficMetricsJob.perform_now
    assert_not TrafficPageView.exists?(old.id)
    assert TrafficPageView.exists?(current.id)
    assert_not TrafficRequestMetric.exists?(old_metric.id)
    assert TrafficRequestMetric.exists?(endpoint: "GET current")
  end
end
