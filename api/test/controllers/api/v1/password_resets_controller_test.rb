require "test_helper"

class Api::V1::PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  test "requests a password reset email for an existing account" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")

    assert_emails 1 do
      post api_v1_password_reset_url,
        params: {
          password_reset: {
            email: user.email
          }
        },
        as: :json
    end

    assert_response :success
    assert_equal "If the email exists, password reset instructions have been sent.", response.parsed_body["message"]

    email = ActionMailer::Base.deliveries.last
    assert_equal [ "client@example.com" ], email.to
    assert_equal "Reset your password", email.subject
    assert_includes email.parts.map { |part| part.body.decoded }.join("\n"), "/password-reset?token="

    user.reload
    assert user.password_reset_token_digest.present?
    assert user.password_reset_sent_at.present?
  end

  test "does not reveal whether a password reset account exists" do
    assert_no_emails do
      post api_v1_password_reset_url,
        params: {
          password_reset: {
            email: "missing@example.com"
          }
        },
        as: :json
    end

    assert_response :success
    assert_equal "If the email exists, password reset instructions have been sent.", response.parsed_body["message"]
  end

  test "updates the password when the token is valid" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    token = user.issue_password_reset_token!

    patch api_v1_password_reset_url,
      params: {
        password_reset: {
          token: token,
          password: "newpassword456"
        }
      },
      as: :json

    assert_response :success
    assert_equal "Password updated successfully.", response.parsed_body["message"]

    user.reload
    assert user.authenticate("newpassword456")
    assert_nil user.auth_token_digest
    assert_nil user.password_reset_token_digest
    assert_nil user.password_reset_sent_at
  end

  test "rejects an expired reset token" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    token = user.issue_password_reset_token!
    user.update!(password_reset_sent_at: 31.minutes.ago)

    patch api_v1_password_reset_url,
      params: {
        password_reset: {
          token: token,
          password: "newpassword456"
        }
      },
      as: :json

    assert_response :unauthorized
    assert_equal "token is invalid or expired", response.parsed_body.dig("errors", "password_reset").first
  end
end
