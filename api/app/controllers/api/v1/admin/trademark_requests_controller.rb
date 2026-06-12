module Api
  module V1
    module Admin
      class TrademarkRequestsController < BaseController
        before_action :authenticate_admin!
        before_action :set_trademark_request

        def update
          changes = tracked_changes

          if @trademark_request.update(trademark_request_params)
            log_events(changes)
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

        def tracked_changes
          trademark_request_params.to_h.filter_map do |field, new_value|
            old_value = @trademark_request.public_send(field).to_s
            normalized_new_value = new_value.to_s
            next if old_value == normalized_new_value

            {
              field_name: field,
              old_value: old_value,
              new_value: normalized_new_value,
              action: field == "status" ? "status_changed" : "admin_comments_changed"
            }
          end
        end

        def log_events(changes)
          changes.each do |change|
            @trademark_request.events.create!(
              admin_user: current_user,
              action: change[:action],
              field_name: change[:field_name],
              old_value: change[:old_value],
              new_value: change[:new_value]
            )
          end
        end

        def serialize_order(order)
          {
            id: order.id,
            admin_comments: order.admin_comments.to_s,
            status: order.status,
            events: order.events.order(created_at: :desc).limit(20).map { |event| serialize_event(event) },
            updated_at: order.updated_at.iso8601
          }
        end

        def serialize_event(event)
          {
            id: event.id,
            action: event.action,
            field_name: event.field_name,
            old_value: event.old_value,
            new_value: event.new_value,
            admin_email: event.admin_user&.email,
            created_at: event.created_at.iso8601
          }
        end
      end
    end
  end
end
