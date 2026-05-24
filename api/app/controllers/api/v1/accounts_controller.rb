module Api
  module V1
    class AccountsController < BaseController
      before_action :authenticate_user!

      def show
        purchases = account_purchases

        render json: {
          account: {
            email: current_user.email,
            billing_profile: serialize_billing_profile(current_user),
            purchases_count: purchases.count,
            total_spent: purchases.sum(:total_cents) / 100,
            purchases: purchases.map { |purchase| serialize_purchase(purchase) }
          }
        }
      end

      def update
        current_user.update!(account_params)

        render json: {
          account: {
            email: current_user.email,
            billing_profile: serialize_billing_profile(current_user)
          },
          user: serialize_user(current_user),
          message: "Datele de contact si facturare au fost salvate."
        }
      rescue ActiveRecord::RecordInvalid => error
        render json: { message: error.record.errors.full_messages.to_sentence, errors: error.record.errors.to_hash },
          status: :unprocessable_entity
      end

      private

      def account_params
        params.require(:account).permit(:phone, :owner_type, :tax_id, :owner_name, :address)
      end

      def serialize_billing_profile(user)
        {
          phone: user.phone,
          owner_type: user.owner_type,
          tax_id: user.tax_id,
          owner_name: user.owner_name,
          address: user.address,
          complete: user.billing_complete?
        }
      end

      def account_purchases
        TrademarkRequest
          .where("user_id = :user_id OR lower(email) = :email", user_id: current_user.id, email: current_user.email)
          .order(created_at: :desc)
      end

      def serialize_purchase(purchase)
        {
          id: purchase.id,
          product_code: purchase.product_code,
          product_name: purchase.product_name,
          mark: purchase.mark,
          classes: purchase.classes_count,
          status: purchase.status,
          payment_method: purchase.payment_method,
          total: {
            amount: purchase.total_lei,
            currency: purchase.currency,
            formatted: purchase.formatted_total
          },
          created_at: purchase.created_at.iso8601
        }
      end
    end
  end
end
