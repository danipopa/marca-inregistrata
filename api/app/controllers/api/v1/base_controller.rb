module Api
  module V1
    class BaseController < ApplicationController
      before_action :handle_options_request
      after_action :set_cors_headers

      private

      def handle_options_request
        head :ok if request.options?
      end

      def set_cors_headers
        response.set_header("Access-Control-Allow-Origin", allowed_origin)
        response.set_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        response.set_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
      end

      def allowed_origin
        request.headers["Origin"].presence || "http://localhost:3000"
      end
    end
  end
end
