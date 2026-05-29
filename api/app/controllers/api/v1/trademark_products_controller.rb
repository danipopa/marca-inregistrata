module Api
  module V1
    class TrademarkProductsController < BaseController
      def index
        render json: {
          products: TrademarkProduct.active.ordered.map { |product| serialize_product(product) }
        }
      end

      private

      def serialize_product(product)
        product.as_catalog_json(image_url: image_url_for(product))
      end

      def image_url_for(product)
        product_image_id = ProductImage.id_from_image_key(product.image_key)
        return unless product_image_id

        api_v1_product_image_url(product_image_id)
      end
    end
  end
end
