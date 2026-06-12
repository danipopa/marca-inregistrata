module Api
  module V1
    module Admin
      class UsersMfaController < BaseController
        before_action :authenticate_admin!

        def destroy
          user = User.find(params[:user_id])
          user.reset_mfa!

          render json: {
            user: serialize_user(user.reload),
            message: "MFA was reset for this user."
          }
        end
      end
    end
  end
end
