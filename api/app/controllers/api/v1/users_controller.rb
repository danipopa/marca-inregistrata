module Api
  module V1
    class UsersController < BaseController
      def create
        user = User.create_with_password!(
          email: user_params[:email],
          password: user_params[:password]
        )

        render json: {
          token: user.issue_auth_token!,
          user: serialize_user(user)
        }, status: :created
      rescue ActiveRecord::RecordInvalid => error
        errors = error.record.errors.to_hash.presence || { password: ["must be at least 8 characters"] }

        render json: { message: errors.to_a.map { |field, messages| "#{field} #{messages.to_sentence}" }.to_sentence, errors: errors },
          status: :unprocessable_entity
      end

      private

      def user_params
        params.require(:user).permit(:email, :password)
      end
    end
  end
end
