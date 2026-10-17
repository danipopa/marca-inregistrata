require "test_helper"

class RequestTrafficTest < ActiveSupport::TestCase
  test "records aggregated status timing and route without raw path or query" do
    env = { "PATH_INFO" => "/api/v1/trademark_requests/123", "REQUEST_METHOD" => "PATCH", "QUERY_STRING" => "token=secret", "action_dispatch.request.path_parameters" => { controller: "api/v1/admin/trademark_requests", action: "update", id: "123" } }
    middleware = RequestTraffic.new(->(_) { [ 422, {}, [ "invalid" ] ] })
    2.times { assert_equal 422, middleware.call(env)[0] }
    metric = TrafficRequestMetric.find_by!(endpoint: "PATCH api/v1/admin/trademark_requests#update", status: 422)
    assert_equal 2, metric.requests_count
    assert metric.duration_ms_total >= 0
    assert_not metric.attributes.values.join.include?("secret")
    assert_not metric.attributes.values.join.include?("123")
  end

  test "records failures without swallowing exceptions and skips health and analytics" do
    app = RequestTraffic.new(->(_) { raise "test failure" })
    assert_raises(RuntimeError) { app.call({ "PATH_INFO" => "/api/failure", "REQUEST_METHOD" => "GET" }) }
    assert_equal 1, TrafficRequestMetric.find_by!(endpoint: "GET (unmatched)", status: 500).requests_count
    middleware = RequestTraffic.new(->(_) { [ 200, {}, [] ] })
    assert_no_difference("TrafficRequestMetric.count") do
      %w[/up /api/v1/traffic_page_views /api/v1/admin/traffic].each { |path| middleware.call({ "PATH_INFO" => path, "REQUEST_METHOD" => "GET" }) }
    end
  end
end
