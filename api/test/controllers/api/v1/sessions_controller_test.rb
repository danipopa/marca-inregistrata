require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "logs in and returns current user" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")

    post api_v1_session_url,
      params: {
        session: {
          email: "client@example.com",
          password: "password123"
        }
      },
      as: :json

    assert_response :success
    assert_equal true, response.parsed_body["mfa_required"]
    assert_equal true, response.parsed_body["mfa_setup_required"]
    assert response.parsed_body["mfa_token"].present?
    assert response.parsed_body.dig("mfa", "secret").present?
    user.reload

    post "/api/v1/session/mfa",
      params: {
        session: {
          mfa_token: response.parsed_body["mfa_token"],
          otp_code: otp_code_for(user)
        }
      },
      as: :json

    assert_response :success
    token = response.parsed_body["token"]
    assert token.present?
    assert_equal User::RECOVERY_CODE_COUNT, response.parsed_body["recovery_codes"].length
    assert_equal User::RECOVERY_CODE_COUNT, response.parsed_body["recovery_codes_remaining"]

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
    assert_equal true, response.parsed_body["mfa_required"]
    assert_equal "client@example.com", response.parsed_body.dig("user", "email")
    assert_equal "google-123", User.find_by(email: "client@example.com").google_sub
  end

  test "rejects invalid mfa code" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    challenge = user.issue_mfa_challenge!
    user.ensure_otp_secret!

    post "/api/v1/session/mfa",
      params: {
        session: {
          mfa_token: challenge,
          otp_code: "000000"
        }
      },
      as: :json

    assert_response :unauthorized
    assert_equal 1, user.reload.mfa_failed_attempts
  end

  test "locks mfa after repeated invalid codes" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    challenge = user.issue_mfa_challenge!
    user.ensure_otp_secret!

    User::MAX_MFA_ATTEMPTS.times do
      post "/api/v1/session/mfa",
        params: {
          session: {
            mfa_token: challenge,
            otp_code: "000000"
          }
        },
        as: :json
    end

    assert_response :too_many_requests
    assert_equal "is temporarily locked", response.parsed_body.dig("errors", "mfa").first
    assert user.reload.mfa_locked?
  end

  test "rejects login challenge while mfa is locked" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    user.update!(mfa_failed_attempts: User::MAX_MFA_ATTEMPTS, mfa_locked_until: 10.minutes.from_now)

    post api_v1_session_url,
      params: {
        session: {
          email: "client@example.com",
          password: "password123"
        }
      },
      as: :json

    assert_response :too_many_requests
  end

  test "accepts recovery code once for mfa" do
    user = User.create_with_password!(email: "client@example.com", password: "password123")
    enable_mfa_for(user)
    recovery_code = user.generate_recovery_codes!.first
    challenge = user.issue_mfa_challenge!

    post "/api/v1/session/mfa",
      params: {
        session: {
          mfa_token: challenge,
          otp_code: recovery_code
        }
      },
      as: :json

    assert_response :success
    assert response.parsed_body["token"].present?
    assert_equal User::RECOVERY_CODE_COUNT - 1, response.parsed_body["recovery_codes_remaining"]

    second_challenge = user.reload.issue_mfa_challenge!
    post "/api/v1/session/mfa",
      params: {
        session: {
          mfa_token: second_challenge,
          otp_code: recovery_code
        }
      },
      as: :json

    assert_response :unauthorized
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
