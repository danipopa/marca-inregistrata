module Api
  module V1
    class BaseController < ApplicationController
      before_action :handle_options_request
      after_action :set_cors_headers

      attr_reader :current_user

      private

      def authenticate_user!
        @current_user = User.find_by_token(bearer_token)
        if @current_user&.mfa_enabled?
          return
        elsif @current_user
          @current_user.clear_auth_token!
          render json: { errors: { mfa: ["is required"] } }, status: :forbidden
          return
        end

        render json: { errors: { auth: ["is required"] } }, status: :unauthorized
      end

      def authenticate_admin!
        authenticate_user!
        return if performed?
        return if current_user.admin?

        render json: { errors: { admin: ["access is required"] } }, status: :forbidden
      end

      def optional_user
        user = User.find_by_token(bearer_token)
        @current_user ||= user if user&.mfa_enabled?
      end

      def bearer_token
        request.authorization.to_s.delete_prefix("Bearer ").presence
      end

      def serialize_user(user)
        {
          id: user.id,
          email: user.email,
          name: user.name,
          owner_name: user.owner_name,
          admin: user.admin?,
          mfa_enabled: user.mfa_enabled?,
          billing_complete: user.billing_complete?
        }
      end

      def serialize_mfa_challenge(user)
        user.ensure_otp_secret!
        {
          mfa_required: true,
          mfa_setup_required: !user.mfa_enabled?,
          mfa_token: user.issue_mfa_challenge!,
          mfa: user.mfa_enabled? ? nil : {
            secret: user.otp_secret,
            provisioning_uri: TotpAuthenticator.provisioning_uri(email: user.email, secret: user.otp_secret)
          },
          user: serialize_user(user)
        }
      end

      def render_mfa_locked(user)
        render json: {
          message: "Too many invalid authenticator codes. Try again later.",
          errors: { mfa: ["is temporarily locked"] },
          locked_until: user.mfa_locked_until
        }, status: :too_many_requests
      end

      def handle_options_request
        if request.options?
          set_cors_headers
          head :ok
        end
      end

      def set_cors_headers
        response.set_header("Access-Control-Allow-Origin", allowed_origin)
        response.set_header("Access-Control-Allow-Methods", "GET, POST, PATCH, DELETE, OPTIONS")
        response.set_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
      end

      def allowed_origin
        request.headers["Origin"].presence || "http://localhost:3000"
      end
    end
  end
end
