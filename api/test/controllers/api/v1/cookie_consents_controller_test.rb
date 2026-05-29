require "test_helper"

class Api::V1::CookieConsentsControllerTest < ActionDispatch::IntegrationTest
  test "records cookie consent proof" do
    assert_difference("CookieConsent.count", 1) do
      post api_v1_cookie_consents_url,
        params: {
          cookie_consent: {
            consent_id: "consent-test-1",
            version: "2026-05-28",
            accepted: true
          }
        },
        headers: { "User-Agent" => "Consent test browser" },
        as: :json
    end

    assert_response :created
    consent = CookieConsent.last
    assert_equal "consent-test-1", consent.consent_id
    assert_equal "2026-05-28", consent.version
    assert_equal true, consent.accepted
    assert_equal "Consent test browser", consent.user_agent
    assert_equal "consent-test-1", response.parsed_body.dig("consent", "consent_id")
  end

  test "updates existing consent proof without duplicate rows" do
    CookieConsent.create!(
      consent_id: "consent-test-1",
      version: "old",
      accepted: true,
      accepted_at: 1.day.ago
    )

    assert_no_difference("CookieConsent.count") do
      post api_v1_cookie_consents_url,
        params: {
          cookie_consent: {
            consent_id: "consent-test-1",
            version: "2026-05-28",
            accepted: true
          }
        },
        as: :json
    end

    assert_response :created
    assert_equal "2026-05-28", CookieConsent.find_by!(consent_id: "consent-test-1").version
  end

  test "records rejected cookie consent proof" do
    post api_v1_cookie_consents_url,
      params: {
        cookie_consent: {
          consent_id: "consent-test-rejected",
          version: "2026-05-28",
          accepted: false
        }
      },
      as: :json

    assert_response :created
    consent = CookieConsent.find_by!(consent_id: "consent-test-rejected")
    assert_equal false, consent.accepted
    assert_equal false, response.parsed_body.dig("consent", "accepted")
  end
end
