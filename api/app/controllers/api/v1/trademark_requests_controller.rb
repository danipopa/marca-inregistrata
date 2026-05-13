module Api
  module V1
    class TrademarkRequestsController < BaseController
      def create
        unless ActiveModel::Type::Boolean.new.cast(request_params[:terms])
          return render json: { errors: { terms: ["must be accepted"] } }, status: :unprocessable_entity
        end

        trademark_request = TrademarkRequest.new(trademark_request_attributes)

        if trademark_request.save
          render json: serialize(trademark_request), status: :created
        else
          render json: { errors: trademark_request.errors.to_hash }, status: :unprocessable_entity
        end
      end

      private

      def request_params
        params.require(:trademark_request).permit(
          :mark,
          :classes,
          :primary_class,
          :goods,
          :email,
          :phone,
          :owner_type,
          :tax_id,
          :owner_name,
          :address,
          :payment,
          :terms
        )
      end

      def trademark_request_attributes
        request_params.except(:classes, :payment, :terms).merge(
          classes_count: request_params[:classes],
          payment_method: request_params[:payment]
        )
      end

      def serialize(trademark_request)
        {
          id: trademark_request.id,
          status: trademark_request.status,
          total: {
            amount: trademark_request.total_lei,
            currency: trademark_request.currency,
            formatted: "#{trademark_request.total_lei.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse} Lei"
          },
          message: "Solicitarea a fost inregistrata."
        }
      end
    end
  end
end
