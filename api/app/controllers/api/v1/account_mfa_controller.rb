module Api
  module V1
    class AccountMfaController < BaseController
      before_action :authenticate_user!

      def reset
        unless current_user.authenticate(mfa_params[:password])
          render json: { errors: { password: ["is invalid"] } }, status: :unauthorized
          return
        end

        unless current_user.verify_otp_code(mfa_params[:otp_code]) || current_user.verify_recovery_code(mfa_params[:otp_code])
          render json: { errors: { otp_code: ["is invalid"] } }, status: :unauthorized
          return
        end

        current_user.reset_mfa!
        render json: serialize_mfa_challenge(current_user.reload)
      end

      private

      def mfa_params
        params.require(:mfa).permit(:password, :otp_code)
      end
    end
  end
end
