module Api
  module V1
    class ProductImagesController < BaseController
      def show
        product_image = ProductImage.find(params[:id])

        expires_in 1.hour, public: true
        send_data product_image.file.download,
          type: product_image.file.content_type,
          disposition: "inline",
          filename: product_image.file.filename.to_s
      end
    end
  end
end
