require "test_helper"

class Api::V1::TrademarkMonitoringControllerTest < ActionDispatch::IntegrationTest
  test "searches trademarks through public register client" do
    with_tmview_search(tmview_payload) do
      post api_v1_trademark_monitoring_search_url,
        params: {
          monitoring: {
            mark: "BRAND",
            offices: %w[RO EM],
            classes: %w[35]
          }
        },
        as: :json
    end

    assert_response :success
    assert_equal "Public trademark registers", response.parsed_body["source"]
    assert_equal 1, response.parsed_body["total"]
    assert_equal "BRAND", response.parsed_body.dig("results", 0, "name")
  end

  test "requires a searchable mark" do
    post api_v1_trademark_monitoring_search_url,
      params: { monitoring: { mark: "A" } },
      as: :json

    assert_response :unprocessable_entity
    assert_equal ["must be at least 2 characters"], response.parsed_body.dig("errors", "mark")
  end

  test "returns bad gateway when trademark search fails" do
    with_tmview_search(->(**) { raise TrademarkMonitoring::TmviewClient::Error.new("Trademark search failed.", status: "503") }) do
      post api_v1_trademark_monitoring_search_url,
        params: { monitoring: { mark: "BRAND" } },
        as: :json
    end

    assert_response :bad_gateway
    assert_equal "Trademark search failed.", response.parsed_body["message"]
  end

  private

  def with_tmview_search(result)
    original = TrademarkMonitoring::TmviewClient.method(:search)
    TrademarkMonitoring::TmviewClient.define_singleton_method(:search) do |**arguments|
      result.respond_to?(:call) ? result.call(**arguments) : result
    end
    yield
  ensure
    TrademarkMonitoring::TmviewClient.define_singleton_method(:search, original)
  end

  def tmview_payload
    {
      source: "Public trademark registers",
      query: { basicSearch: "BRAND" },
      total: 1,
      results: [
        {
          id: "RO123",
          name: "BRAND",
          office: "RO",
          status: "Registered",
          nice_classes: ["35"]
        }
      ]
    }
  end
end
