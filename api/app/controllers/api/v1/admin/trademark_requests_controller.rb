module Api
  module V1
    module Admin
      class TrademarkRequestsController < BaseController
        before_action :authenticate_admin!
        before_action :set_trademark_request

        def update
          if @trademark_request.update(trademark_request_params)
            render json: { order: serialize_order(@trademark_request) }
          else
            render json: { errors: @trademark_request.errors.to_hash }, status: :unprocessable_entity
          end
        end

        private

        def set_trademark_request
          @trademark_request = TrademarkRequest.find(params[:id])
        end

        def trademark_request_params
          params.require(:trademark_request).permit(:admin_comments, :status)
        end

        def serialize_order(order)
          {
            id: order.id,
            admin_comments: order.admin_comments.to_s,
            status: order.status,
            updated_at: order.updated_at.iso8601
          }
        end
      end
    end
  end
end
