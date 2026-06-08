module Api
  module V1
    class BaseController < ApplicationController
      before_action :handle_options_request
      after_action :set_cors_headers

      attr_reader :current_user

      private

      def authenticate_user!
        @current_user = User.find_by_token(bearer_token)
        return if @current_user

        render json: { errors: { auth: ["is required"] } }, status: :unauthorized
      end

      def authenticate_admin!
        authenticate_user!
        return if performed?
        return if current_user.admin?

        render json: { errors: { admin: ["access is required"] } }, status: :forbidden
      end

      def optional_user
        @current_user ||= User.find_by_token(bearer_token)
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
          billing_complete: user.billing_complete?
        }
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
