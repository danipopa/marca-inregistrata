require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  test "registers a user and returns an mfa challenge" do
    assert_difference("User.count", 1) do
      post api_v1_users_url,
        params: {
          user: {
            email: "client@example.com",
            password: "password123"
          }
        },
        as: :json
    end

    assert_response :created
    assert_equal true, response.parsed_body["mfa_required"]
    assert_equal true, response.parsed_body["mfa_setup_required"]
    assert response.parsed_body["mfa_token"].present?
    assert response.parsed_body.dig("mfa", "secret").present?
    assert_equal "client@example.com", response.parsed_body.dig("user", "email")
  end

  test "returns validation errors when registration is invalid" do
    assert_no_difference("User.count") do
      post api_v1_users_url,
        params: {
          user: {
            email: "client@example.com",
            password: "short"
          }
        },
        as: :json
    end

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["message"], "password"
    assert_equal ["must be at least 8 characters"], response.parsed_body.dig("errors", "password")
  end
end
