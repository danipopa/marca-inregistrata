module Api
  module V1
    class TrademarkProductsController < BaseController
      def index
        render json: {
          products: TrademarkProduct.active.ordered.map(&:as_catalog_json)
        }
      end
    end
  end
end
