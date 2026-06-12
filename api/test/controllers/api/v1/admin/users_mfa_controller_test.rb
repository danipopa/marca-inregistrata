require "test_helper"

class Api::V1::Admin::UsersMfaControllerTest < ActionDispatch::IntegrationTest
  test "admin resets user mfa" do
    admin = User.create_with_password!(email: "admin@example.com", password: "password123")
    admin.update!(admin: true)
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    enable_mfa_for(user)
    user.generate_recovery_codes!
    user.issue_auth_token!

    delete "/api/v1/admin/users/#{user.id}/mfa",
      headers: { "Authorization" => "Bearer #{issue_mfa_auth_token(admin)}" },
      as: :json

    assert_response :success
    assert_equal false, response.parsed_body.dig("user", "mfa_enabled")
    user.reload
    assert_nil user.otp_secret
    assert_nil user.otp_enabled_at
    assert_nil user.recovery_codes_digest
    assert_nil user.auth_token_digest
  end

  test "non admin cannot reset user mfa" do
    client = User.create_with_password!(email: "client@example.com", password: "password123")
    user = User.create_with_password!(email: "other@example.com", password: "password123")
    enable_mfa_for(user)

    delete "/api/v1/admin/users/#{user.id}/mfa",
      headers: { "Authorization" => "Bearer #{issue_mfa_auth_token(client)}" },
      as: :json

    assert_response :forbidden
    assert user.reload.mfa_enabled?
  end
end
