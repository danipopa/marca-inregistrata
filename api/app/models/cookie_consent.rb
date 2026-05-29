class CookieConsent < ApplicationRecord
  validates :consent_id, :version, :accepted_at, presence: true
  validates :consent_id, uniqueness: true
end
