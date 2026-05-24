require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "logs in and returns current user" do
    User.create_with_password!(email: "client@example.com", password: "password123")

    post api_v1_session_url,
      params: {
        session: {
          email: "client@example.com",
          password: "password123"
        }
      },
      as: :json

    assert_response :success
    token = response.parsed_body["token"]
    assert token.present?

    get api_v1_session_url, headers: { "Authorization" => "Bearer #{token}" }, as: :json

    assert_response :success
    assert_equal "client@example.com", response.parsed_body.dig("user", "email")
    assert_equal false, response.parsed_body.dig("user", "admin")
  end

  test "signs in with google credential" do
    with_google_identity({ google_sub: "google-123", email: "client@example.com", name: "Client Example" }) do
      assert_difference("User.count", 1) do
        post api_v1_session_google_url,
          params: { credential: "google-id-token" },
          as: :json
      end
    end

    assert_response :success
    assert response.parsed_body["token"].present?
    assert_equal "client@example.com", response.parsed_body.dig("user", "email")
    assert_equal "google-123", User.find_by(email: "client@example.com").google_sub
  end

  test "returns an error when google credential is invalid" do
    with_google_identity(-> { raise GoogleIdentity::VerificationError, "Google credential could not be verified" }) do
      post api_v1_session_google_url,
        params: { credential: "bad-token" },
        as: :json
    end

    assert_response :unauthorized
    assert_equal "Google credential could not be verified", response.parsed_body["message"]
  end

  private

  def with_google_identity(result)
    original = GoogleIdentity.method(:verify!)
    GoogleIdentity.define_singleton_method(:verify!) do |*|
      result.respond_to?(:call) ? result.call : result
    end
    yield
  ensure
    GoogleIdentity.define_singleton_method(:verify!, original)
  end
end
