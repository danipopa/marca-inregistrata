module Api
  module V1
    module Admin
      class ProductImagesController < BaseController
        before_action :authenticate_admin!

        def index
          render json: { images: ProductImage.ordered.map { |image| serialize_image(image) } }
        end

        def create
          image = ProductImage.new(
            name: product_image_params[:name].presence || product_image_params[:file]&.original_filename,
            file: product_image_params[:file]
          )

          if image.save
            render json: { image: serialize_image(image) }, status: :created
          else
            render json: { errors: image.errors.to_hash }, status: :unprocessable_entity
          end
        end

        def destroy
          ProductImage.find(params[:id]).destroy
          head :no_content
        end

        private

        def product_image_params
          params.require(:product_image).permit(:name, :file)
        end

        def serialize_image(image)
          {
            id: image.id,
            key: image.image_key,
            name: image.name,
            filename: image.file.filename.to_s,
            content_type: image.file.content_type,
            url: api_v1_product_image_url(image)
          }
        end
      end
    end
  end
end
