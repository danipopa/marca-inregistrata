class User < ApplicationRecord
  PASSWORD_ITERATIONS = 65_536
  PASSWORD_LENGTH = 32
  MAX_MFA_ATTEMPTS = 5
  MFA_LOCK_DURATION = 15.minutes
  RECOVERY_CODE_COUNT = 10
  RECOVERY_CODE_LENGTH = 12

  has_many :trademark_requests, dependent: :nullify

  encrypts :otp_secret

  before_validation :normalize_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :google_sub, uniqueness: true, allow_blank: true
  validates :password_digest, :password_salt, presence: true

  def self.create_with_password!(email:, password:)
    user = new(email: email)
    user.password = password
    user.save!
    user
  end

  def self.from_google!(google_sub:, email:, name: nil)
    user = find_by(google_sub: google_sub) || find_by(email: email.to_s.strip.downcase) || new(email: email)
    user.google_sub ||= google_sub
    user.name = name if name.present?
    user.password = SecureRandom.urlsafe_base64(32) if user.password_digest.blank?
    user.save!
    user
  end

  def self.authenticate(email:, password:)
    user = find_by(email: email.to_s.strip.downcase)
    return unless user&.authenticate(password)

    user
  end

  def self.find_by_token(token)
    return if token.blank?

    find_by(auth_token_digest: digest_token(token))
  end

  def self.digest_token(token)
    OpenSSL::Digest::SHA256.hexdigest(token)
  end

  def password=(password)
    if password.to_s.length < 8
      errors.add(:password, "must be at least 8 characters")
      raise ActiveRecord::RecordInvalid, self
    end

    self.password_salt = SecureRandom.hex(16)
    self.password_digest = self.class.password_hash(password, password_salt)
  end

  def authenticate(password)
    return false if password.blank?

    ActiveSupport::SecurityUtils.secure_compare(
      password_digest,
      self.class.password_hash(password, password_salt)
    )
  end

  def issue_auth_token!
    token = SecureRandom.urlsafe_base64(32)
    update!(auth_token_digest: self.class.digest_token(token), auth_token_created_at: Time.current)
    token
  end

  def mfa_enabled?
    otp_secret.present? && otp_enabled_at.present?
  end

  def ensure_otp_secret!
    return otp_secret if otp_secret.present?

    update!(otp_secret: TotpAuthenticator.generate_secret)
    otp_secret
  end

  def issue_mfa_challenge!
    token = SecureRandom.urlsafe_base64(32)
    update!(mfa_challenge_digest: self.class.digest_token(token), mfa_challenge_created_at: Time.current)
    token
  end

  def valid_mfa_challenge?(token)
    return false if token.blank? || mfa_challenge_digest.blank? || mfa_challenge_created_at.blank?
    return false if mfa_challenge_created_at < 10.minutes.ago

    ActiveSupport::SecurityUtils.secure_compare(mfa_challenge_digest, self.class.digest_token(token))
  end

  def mfa_locked?
    mfa_locked_until.present? && mfa_locked_until.future?
  end

  def record_failed_mfa_attempt!
    attempts = mfa_failed_attempts + 1
    attributes = { mfa_failed_attempts: attempts }
    attributes[:mfa_locked_until] = MFA_LOCK_DURATION.from_now if attempts >= MAX_MFA_ATTEMPTS
    update!(attributes)
  end

  def reset_mfa_attempts!
    update!(mfa_failed_attempts: 0, mfa_locked_until: nil)
  end

  def verify_otp_code(code)
    return false unless otp_secret.present?

    TotpAuthenticator.verify?(otp_secret, code)
  end

  def generate_recovery_codes!
    codes = Array.new(RECOVERY_CODE_COUNT) { formatted_recovery_code }
    update!(recovery_codes_digest: JSON.generate(codes.map { |code| self.class.digest_token(normalize_recovery_code(code)) }))
    codes
  end

  def verify_recovery_code(code)
    normalized_code = normalize_recovery_code(code)
    return false if normalized_code.blank?

    digests = recovery_code_digests
    digest = self.class.digest_token(normalized_code)
    return false unless digests.include?(digest)

    digests.delete(digest)
    update!(recovery_codes_digest: JSON.generate(digests))
    true
  end

  def recovery_codes_remaining
    recovery_code_digests.length
  end

  def enable_mfa!
    update!(otp_enabled_at: Time.current)
  end

  def clear_mfa_challenge!
    update!(mfa_challenge_digest: nil, mfa_challenge_created_at: nil)
  end

  def reset_mfa!
    update!(
      otp_secret: nil,
      otp_enabled_at: nil,
      recovery_codes_digest: nil,
      mfa_challenge_digest: nil,
      mfa_challenge_created_at: nil,
      mfa_failed_attempts: 0,
      mfa_locked_until: nil,
      auth_token_digest: nil,
      auth_token_created_at: nil
    )
  end

  def clear_auth_token!
    update!(auth_token_digest: nil, auth_token_created_at: nil)
  end

  def billing_complete?
    phone.present? && owner_type.present? && owner_name.present? && address.present?
  end

  def self.password_hash(password, salt)
    OpenSSL::PKCS5.pbkdf2_hmac(password, salt, PASSWORD_ITERATIONS, PASSWORD_LENGTH, "sha256").unpack1("H*")
  end

  private

  def recovery_code_digests
    JSON.parse(recovery_codes_digest.presence || "[]")
  rescue JSON::ParserError
    []
  end

  def formatted_recovery_code
    SecureRandom.alphanumeric(RECOVERY_CODE_LENGTH).upcase.scan(/.{1,4}/).join("-")
  end

  def normalize_recovery_code(code)
    code.to_s.upcase.gsub(/[^A-Z0-9]/, "")
  end

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
