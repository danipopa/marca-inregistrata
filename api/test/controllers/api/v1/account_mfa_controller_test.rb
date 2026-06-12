require "test_helper"

class Api::V1::AccountMfaControllerTest < ActionDispatch::IntegrationTest
  test "resets own mfa with password and current code" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    token = issue_mfa_auth_token(user)
    old_secret = user.otp_secret

    post "/api/v1/account/mfa/reset",
      params: {
        mfa: {
          password: "password123",
          otp_code: otp_code_for(user)
        }
      },
      headers: { "Authorization" => "Bearer #{token}" },
      as: :json

    assert_response :success
    assert_equal true, response.parsed_body["mfa_required"]
    assert_equal true, response.parsed_body["mfa_setup_required"]
    assert response.parsed_body["mfa_token"].present?
    assert response.parsed_body.dig("mfa", "secret").present?
    refute_equal old_secret, response.parsed_body.dig("mfa", "secret")
    assert_nil user.reload.auth_token_digest
  end

  test "rejects own mfa reset with invalid password" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    token = issue_mfa_auth_token(user)

    post "/api/v1/account/mfa/reset",
      params: {
        mfa: {
          password: "wrong-password",
          otp_code: otp_code_for(user)
        }
      },
      headers: { "Authorization" => "Bearer #{token}" },
      as: :json

    assert_response :unauthorized
    assert user.reload.mfa_enabled?
  end
end
