ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def enable_mfa_for(user)
      user.update!(otp_secret: TotpAuthenticator.generate_secret, otp_enabled_at: Time.current)
      user
    end

    def issue_mfa_auth_token(user)
      enable_mfa_for(user) unless user.mfa_enabled?
      user.issue_auth_token!
    end

    def otp_code_for(user)
      counter = Time.current.to_i / TotpAuthenticator::INTERVAL
      TotpAuthenticator.send(:generate_code, user.otp_secret, counter)
    end
  end
end
