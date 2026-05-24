module Api
  module V1
    class SessionsController < BaseController
      before_action :authenticate_user!, only: %i[show destroy]

      def create
        user = User.authenticate(email: session_params[:email], password: session_params[:password])

        if user
          render json: serialize_session(user, user.issue_auth_token!)
        else
          render json: { errors: { credentials: ["are invalid"] } }, status: :unauthorized
        end
      end

      def google
        identity = GoogleIdentity.verify!(params.require(:credential))
        user = User.from_google!(**identity)

        render json: serialize_session(user, user.issue_auth_token!)
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

      def serialize_session(user, token)
        {
          token: token,
          user: serialize_user(user)
        }
      end
    end
  end
end
