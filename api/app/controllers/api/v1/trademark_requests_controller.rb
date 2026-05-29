module Api
  module V1
    class TrademarkRequestsController < BaseController
      def create
        authenticate_user!
        return if performed?

        unless current_user.billing_complete?
          return render json: {
            message: "Completeaza datele de contact si facturare in cont inainte de checkout.",
            errors: { account: ["billing profile is incomplete"] }
          }, status: :unprocessable_entity
        end

        unless ActiveModel::Type::Boolean.new.cast(request_params[:terms])
          return render json: { errors: { terms: ["must be accepted"] } }, status: :unprocessable_entity
        end

        trademark_request = TrademarkRequest.new(trademark_request_attributes)
        trademark_request.user = current_user

        if trademark_request.save
          attach_checkout!(trademark_request)
          TrademarkRequestMailer.order_created(trademark_request).deliver_now
          render json: serialize(trademark_request), status: :created
        else
          render json: { errors: trademark_request.errors.to_hash }, status: :unprocessable_entity
        end
      rescue Payments::StripeCheckout::MissingCredentials, Payments::PaypalCheckout::MissingCredentials => error
        render json: { message: error.message }, status: :unprocessable_entity
      rescue Payments::StripeCheckout::ProviderError, Payments::PaypalCheckout::ProviderError => error
        render json: { message: error.message }, status: :bad_gateway
      end

      private

      def request_params
        params.require(:trademark_request).permit(
          :mark,
          :product_code,
          :classes,
          :primary_class,
          :goods,
          :payment,
          :terms
        )
      end

      def attach_checkout!(trademark_request)
        checkout = case trademark_request.payment_method
                   when "card"
                     Payments::StripeCheckout.create!(trademark_request)
                   when "paypal"
                     Payments::PaypalCheckout.create!(trademark_request)
                   end

        return unless checkout

        trademark_request.update!(
          payment_provider: checkout[:provider],
          payment_provider_id: checkout[:provider_id],
          payment_checkout_url: checkout[:checkout_url]
        )
      end

      def trademark_request_attributes
        request_params.except(:classes, :payment, :terms).merge(
          classes_count: request_params[:classes],
          payment_method: request_params[:payment],
          email: current_user.email,
          phone: current_user.phone,
          owner_type: current_user.owner_type,
          tax_id: current_user.tax_id,
          owner_name: current_user.owner_name,
          address: current_user.address,
          ip_address: request.remote_ip
        )
      end

      def serialize(trademark_request)
        {
          id: trademark_request.id,
          status: trademark_request.status,
          product: {
            code: trademark_request.product_code,
            name: trademark_request.product_name
          },
          total: {
            amount: trademark_request.total_lei,
            currency: trademark_request.currency,
            formatted: trademark_request.formatted_total
          },
          payment: {
            method: trademark_request.payment_method,
            provider: trademark_request.payment_provider,
            checkout_url: trademark_request.payment_checkout_url
          },
          message: "Comanda a fost inregistrata in contul tau."
        }
      end
    end
  end
end
