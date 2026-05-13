module Api
  module V1
    class PreflightController < BaseController
      def show
        head :ok
      end
    end
  end
end
