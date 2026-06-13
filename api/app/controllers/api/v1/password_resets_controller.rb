module Api
  module V1
    class PasswordResetsController < ApplicationController
      def create
        user = User.find_by(email: password_reset_params[:email].to_s.strip.downcase)
        user&.tap do |account|
          token = account.issue_password_reset_token!
          UserMailer.password_reset(account, token).deliver_now
        end

        render json: { message: "If the email exists, password reset instructions have been sent." }
      end

      def update
        user = User.find_by(password_reset_token_digest: User.digest_token(password_reset_params[:token]))

        unless user&.valid_password_reset_token?(password_reset_params[:token])
          render json: { errors: { password_reset: ["token is invalid or expired"] } }, status: :unauthorized
          return
        end

        user.reset_password!(password: password_reset_params[:password])
        render json: { message: "Password updated successfully." }
      rescue ActiveRecord::RecordInvalid => error
        render json: { message: error.record.errors.full_messages.to_sentence, errors: error.record.errors.to_hash },
          status: :unprocessable_entity
      end

      private

      def password_reset_params
        params.require(:password_reset).permit(:email, :token, :password)
      end
    end
  end
end
