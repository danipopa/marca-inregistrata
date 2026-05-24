require "test_helper"

class Api::V1::PreflightControllerTest < ActionDispatch::IntegrationTest
  test "allows frontend preflight requests" do
    options "/api/v1/trademark_requests",
      headers: {
        "Origin" => "http://127.0.0.1:3002",
        "Access-Control-Request-Method" => "POST",
        "Access-Control-Request-Headers" => "content-type"
      }

    assert_response :success
    assert_equal "http://127.0.0.1:3002", response.headers["Access-Control-Allow-Origin"]
    assert_includes response.headers["Access-Control-Allow-Methods"], "POST"
    assert_includes response.headers["Access-Control-Allow-Methods"], "DELETE"
    assert_includes response.headers["Access-Control-Allow-Headers"], "Content-Type"
  end
end
