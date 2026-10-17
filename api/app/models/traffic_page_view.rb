class TrafficPageView < ApplicationRecord
  CONSENT_VERSION = "2026-10-17-analytics-v2"
  PATHS = %w[/ /order /checkout /termeni-si-conditii /politica-de-confidentialitate].freeze

  validates :path, inclusion: { in: PATHS }
  validates :visitor_key, :session_key, presence: true, length: { is: 64 }

  def self.anonymous_key(value)
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.key_generator.generate_key("traffic-analytics", 32), value)
  end
end
