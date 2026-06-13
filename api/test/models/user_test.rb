require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "authenticates with a password" do
    user = User.create_with_password!(email: "CLIENT@example.com", password: "password123")

    assert_equal "client@example.com", user.email
    assert_equal false, user.admin?
    assert_equal user, User.authenticate(email: "client@example.com", password: "password123")
    assert_nil User.authenticate(email: "client@example.com", password: "wrong-password")
  end

  test "finds a user by issued token" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    token = user.issue_auth_token!

    assert_equal user, User.find_by_token(token)
    assert_nil User.find_by_token("not-the-token")
  end

  test "issues and validates password reset tokens" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    token = user.issue_password_reset_token!

    assert user.valid_password_reset_token?(token)
    refute user.valid_password_reset_token?("not-the-token")
    assert user.password_reset_token_digest.present?
    assert user.password_reset_sent_at.present?
  end

  test "resets password and clears auth state" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    auth_token = user.issue_auth_token!
    user.issue_password_reset_token!

    user.reset_password!(password: "newpassword456")

    assert user.authenticate("newpassword456")
    assert_nil user.auth_token_digest
    assert_nil user.password_reset_token_digest
    assert_nil user.password_reset_sent_at
    assert_nil User.find_by_token(auth_token)
  end

  test "creates or links a google identity" do
    existing_user = User.create_with_password!(email: "client@example.com", password: "password123")

    assert_no_difference("User.count") do
      user = User.from_google!(google_sub: "google-123", email: "CLIENT@example.com", name: "Client Example")

      assert_equal existing_user, user
      assert_equal "google-123", user.google_sub
      assert_equal "Client Example", user.name
      assert user.authenticate("password123")
    end
  end
end
