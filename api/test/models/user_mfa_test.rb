require "test_helper"

class UserMfaTest < ActiveSupport::TestCase
  test "stores otp secret encrypted" do
    user = User.create_with_password!(email: "secure@example.com", password: "password123")
    secret = user.ensure_otp_secret!
    raw_secret = User.connection.select_value(
      User.sanitize_sql_array(["SELECT otp_secret FROM users WHERE id = ?", user.id])
    )

    assert_equal secret, user.reload.otp_secret
    refute_equal secret, raw_secret
    assert_includes raw_secret, "\"p\""
  end

  test "locks mfa after repeated failed attempts" do
    user = User.create_with_password!(email: "locked@example.com", password: "password123")

    (User::MAX_MFA_ATTEMPTS - 1).times do
      user.record_failed_mfa_attempt!
      refute user.reload.mfa_locked?
    end

    user.record_failed_mfa_attempt!

    assert user.reload.mfa_locked?
    assert_equal User::MAX_MFA_ATTEMPTS, user.mfa_failed_attempts
    assert user.mfa_locked_until.future?
  end

  test "resets mfa attempts" do
    user = User.create_with_password!(email: "reset@example.com", password: "password123")
    User::MAX_MFA_ATTEMPTS.times { user.record_failed_mfa_attempt! }

    user.reset_mfa_attempts!

    assert_equal 0, user.reload.mfa_failed_attempts
    assert_nil user.mfa_locked_until
  end

  test "generates hashed one time recovery codes" do
    user = User.create_with_password!(email: "recovery@example.com", password: "password123")

    codes = user.generate_recovery_codes!

    assert_equal User::RECOVERY_CODE_COUNT, codes.length
    assert_equal User::RECOVERY_CODE_COUNT, user.recovery_codes_remaining
    refute_includes user.recovery_codes_digest, codes.first
    assert user.verify_recovery_code(codes.first)
    refute user.verify_recovery_code(codes.first)
    assert_equal User::RECOVERY_CODE_COUNT - 1, user.reload.recovery_codes_remaining
  end
end
