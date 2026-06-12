module Api
  module V1
    module Admin
      class DashboardController < BaseController
        before_action :authenticate_admin!

        def show
          orders = TrademarkRequest.includes(:user, events: :admin_user).order(created_at: :desc)

          render json: {
            stats: {
              orders_count: orders.count,
              users_count: User.count,
              revenue_lei: orders.sum(:total_cents) / 100,
              pending_orders_count: orders.where(status: "pending_payment").count
            },
            orders: orders.limit(100).map { |order| serialize_order(order) },
            users: User.order(created_at: :desc).limit(100).map { |user| serialize_admin_user(user) }
          }
        end

        private

        def serialize_order(order)
          {
            id: order.id,
            product_code: order.product_code,
            product_name: order.product_name,
            order_type: order.order_type,
            owner_change_requested: order.owner_change_requested,
            mark: order.mark,
            classes: order.classes_count,
            status: order.status,
            payment_method: order.payment_method,
            email: order.email,
            owner_name: order.owner_name,
            phone: order.phone,
            ip_address: order.ip_address,
            admin_comments: order.admin_comments.to_s,
            events: order.events.sort_by(&:created_at).reverse.first(20).map { |event| serialize_event(event) },
            total: {
              amount: order.total_lei,
              currency: order.currency,
              formatted: order.formatted_total
            },
            user: order.user ? serialize_user(order.user) : nil,
            created_at: order.created_at.iso8601
          }
        end

        def serialize_admin_user(user)
          serialize_user(user).merge(
            orders_count: user.trademark_requests.count,
            created_at: user.created_at.iso8601
          )
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
