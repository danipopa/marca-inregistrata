module Api
  module V1
    class SessionsController < BaseController
      before_action :authenticate_user!, only: %i[show destroy]

      def create
        user = User.authenticate(email: session_params[:email], password: session_params[:password])

        if user
          if user.mfa_locked?
            render_mfa_locked(user)
            return
          end

          render json: serialize_mfa_challenge(user)
        else
          render json: { errors: { credentials: ["are invalid"] } }, status: :unauthorized
        end
      end

      def mfa
        user = User.find_by(mfa_challenge_digest: User.digest_token(mfa_params[:mfa_token]))

        unless user&.valid_mfa_challenge?(mfa_params[:mfa_token])
          render json: { errors: { mfa: ["challenge expired"] } }, status: :unauthorized
          return
        end

        if user.mfa_locked?
          render_mfa_locked(user)
          return
        end

        code_verified = user.verify_otp_code(mfa_params[:otp_code])
        code_verified ||= user.mfa_enabled? && user.verify_recovery_code(mfa_params[:otp_code])

        unless code_verified
          user.record_failed_mfa_attempt!
          if user.mfa_locked?
            render_mfa_locked(user)
            return
          end

          render json: { errors: { otp_code: ["is invalid"] } }, status: :unauthorized
          return
        end

        mfa_was_enabled = user.mfa_enabled?
        user.enable_mfa! unless mfa_was_enabled
        user.clear_mfa_challenge!
        user.reset_mfa_attempts!
        session_payload = serialize_session(user, user.issue_auth_token!)
        session_payload[:recovery_codes] = user.generate_recovery_codes! unless mfa_was_enabled
        session_payload[:recovery_codes_remaining] = user.recovery_codes_remaining if user.mfa_enabled?
        render json: session_payload
      end

      def google
        identity = GoogleIdentity.verify!(params.require(:credential))
        user = User.from_google!(**identity)

        if user.mfa_locked?
          render_mfa_locked(user)
          return
        end

        render json: serialize_mfa_challenge(user)
      rescue GoogleIdentity::VerificationError => error
        render json: { message: error.message, errors: { google: [error.message] } }, status: :unauthorized
      rescue ActiveRecord::RecordInvalid => error
        render json: { message: error.record.errors.full_messages.to_sentence, errors: error.record.errors.to_hash },
          status: :unprocessable_entity
      end

      def show
        render json: { user: serialize_user(current_user) }
      end

      def destroy
        current_user.clear_auth_token!
        head :no_content
      end

      private

      def session_params
        params.require(:session).permit(:email, :password)
      end

      def mfa_params
        params.require(:session).permit(:mfa_token, :otp_code)
      end

      def serialize_session(user, token)
        {
          token: token,
          user: serialize_user(user)
        }
      end
    end
  end
end
