require "net/http"
require "json"

class GoogleIdentity
  TOKENINFO_URL = "https://oauth2.googleapis.com/tokeninfo"

  class VerificationError < StandardError; end

  def self.verify!(credential)
    raise VerificationError, "Google credential is missing" if credential.blank?
    raise VerificationError, "Google client ID is missing" if ENV["GOOGLE_CLIENT_ID"].blank?

    uri = URI(TOKENINFO_URL)
    uri.query = URI.encode_www_form(id_token: credential)
    response = Net::HTTP.get_response(uri)
    payload = JSON.parse(response.body)

    unless response.is_a?(Net::HTTPSuccess)
      raise VerificationError, payload["error_description"].presence || "Google credential could not be verified"
    end

    unless payload["aud"] == ENV["GOOGLE_CLIENT_ID"]
      raise VerificationError, "Google credential audience is invalid"
    end

    unless ActiveModel::Type::Boolean.new.cast(payload["email_verified"])
      raise VerificationError, "Google email is not verified"
    end

    {
      google_sub: payload.fetch("sub"),
      email: payload.fetch("email"),
      name: payload["name"]
    }
  rescue JSON::ParserError
    raise VerificationError, "Google credential response could not be parsed"
  end
end
