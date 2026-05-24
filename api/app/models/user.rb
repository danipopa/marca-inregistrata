class User < ApplicationRecord
  PASSWORD_ITERATIONS = 65_536
  PASSWORD_LENGTH = 32

  has_many :trademark_requests, dependent: :nullify

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

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
