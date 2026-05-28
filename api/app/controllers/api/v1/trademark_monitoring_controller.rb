module Api
  module V1
    class TrademarkMonitoringController < BaseController
      def search
        mark = monitoring_params[:mark].to_s.strip

        if mark.length < 2
          return render json: { errors: { mark: ["must be at least 2 characters"] } }, status: :unprocessable_entity
        end

        result = TrademarkMonitoring::TmviewClient.search(
          mark:,
          offices: monitoring_params[:offices],
          classes: monitoring_params[:classes],
          page_size: monitoring_params[:page_size]
        )

        render json: result
      rescue TrademarkMonitoring::TmviewClient::Error => error
        render json: { message: error.message, status: error.status }, status: :bad_gateway
      end

      private

      def monitoring_params
        params.require(:monitoring).permit(:mark, :page_size, offices: [], classes: [])
      end
    end
  end
end
