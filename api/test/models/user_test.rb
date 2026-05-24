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
