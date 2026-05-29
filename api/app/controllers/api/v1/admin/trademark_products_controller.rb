module Api
  module V1
    module Admin
      class TrademarkProductsController < BaseController
        before_action :authenticate_admin!
        before_action :set_product, only: %i[update destroy]

        def index
          render json: {
            products: TrademarkProduct.ordered.map(&:as_catalog_json)
          }
        end

        def create
          product = TrademarkProduct.new(product_attributes)

          if product.save
            render json: { product: product.as_catalog_json }, status: :created
          else
            render json: { errors: product.errors.to_hash }, status: :unprocessable_entity
          end
        end

        def update
          if @product.update(product_attributes)
            render json: { product: @product.as_catalog_json }
          else
            render json: { errors: @product.errors.to_hash }, status: :unprocessable_entity
          end
        end

        def destroy
          @product.destroy
          head :no_content
        end

        private

        def set_product
          @product = TrademarkProduct.find(params[:id])
        end

        def product_params
          params.require(:trademark_product).permit(
            :code,
            :currency,
            :region,
            :price_label,
            :base_price_lei,
            :title_ro,
            :title_en,
            :note_ro,
            :note_en,
            :tax_ro,
            :tax_en,
            :image_key,
            :position,
            :active,
            items_ro: [],
            items_en: []
          )
        end

        def product_attributes
          product_params.to_h.with_indifferent_access.tap do |attributes|
            attributes[:items_ro_list] = attributes.delete(:items_ro) if attributes.key?(:items_ro)
            attributes[:items_en_list] = attributes.delete(:items_en) if attributes.key?(:items_en)
          end
        end

      end
    end
  end
end
