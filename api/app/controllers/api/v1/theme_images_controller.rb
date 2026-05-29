module Api
  module V1
    class ThemeImagesController < BaseController
      def show
        theme_image = ThemeImage.find(params[:id])

        expires_in 1.hour, public: true
        send_data theme_image.file.download,
          type: theme_image.file.content_type,
          disposition: "inline",
          filename: theme_image.file.filename.to_s
      end
    end
  end
end
