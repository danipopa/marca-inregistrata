module Api
  module V1
    class PaymentVerificationsController < BaseController
      before_action :authenticate_user!

      def create
        trademark_request = accessible_account_purchases.find(params[:purchase_id])
        verified = verify_payment(trademark_request)

        trademark_request.update!(status: "paid") if verified

        render json: {
          order: serialize_order(trademark_request.reload),
          verified: verified,
          message: verified ? "Plata a fost confirmata." : "Plata nu este inca confirmata."
        }
      rescue Payments::StripeCheckout::MissingCredentials, Payments::PaypalCheckout::MissingCredentials => error
        render json: { message: error.message }, status: :unprocessable_entity
      rescue Payments::StripeCheckout::ProviderError, Payments::PaypalCheckout::ProviderError => error
        render json: { message: error.message }, status: :bad_gateway
      end

      private

      def accessible_account_purchases
        TrademarkRequest
          .where("user_id = :user_id OR lower(email) = :email", user_id: current_user.id, email: current_user.email)
      end

      def verify_payment(trademark_request)
        case trademark_request.payment_provider
        when "stripe"
          Payments::StripeCheckout.paid?(trademark_request)
        when "paypal"
          Payments::PaypalCheckout.capture!(trademark_request)
        else
          false
        end
      end

      def serialize_order(order)
        {
          id: order.id,
          status: order.status,
          payment_method: order.payment_method,
          payment_provider: order.payment_provider
        }
      end
    end
  end
end
