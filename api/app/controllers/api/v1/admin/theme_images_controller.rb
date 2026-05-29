module Api
  module V1
    module Admin
      class ThemeImagesController < BaseController
        before_action :authenticate_admin!

        def index
          render json: { images: ThemeImage.ordered.map { |image| serialize_image(image) } }
        end

        def create
          image = ThemeImage.new(
            name: theme_image_params[:name].presence || theme_image_params[:file]&.original_filename,
            file: theme_image_params[:file]
          )

          if image.save
            render json: { image: serialize_image(image) }, status: :created
          else
            render json: { errors: image.errors.to_hash }, status: :unprocessable_entity
          end
        end

        def destroy
          ThemeImage.find(params[:id]).destroy
          head :no_content
        end

        private

        def theme_image_params
          params.require(:theme_image).permit(:name, :file)
        end

        def serialize_image(image)
          {
            id: image.id,
            key: image.image_key,
            name: image.name,
            filename: image.file.filename.to_s,
            content_type: image.file.content_type,
            url: api_v1_theme_image_url(image)
          }
        end
      end
    end
  end
end
