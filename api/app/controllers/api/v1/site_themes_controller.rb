module Api
  module V1
    class SiteThemesController < BaseController
      def show
        render json: { theme: serialize_theme(SiteTheme.current) }
      end

      private

      def serialize_theme(theme)
        theme.as_json.merge(
          hero_image: theme_image_url_for(theme.hero_image_key),
          logo_image: theme_image_url_for(theme.logo_image_key)
        )
      end

      def theme_image_url_for(image_key)
        theme_image_id = ThemeImage.id_from_image_key(image_key)
        return unless theme_image_id

        api_v1_theme_image_url(theme_image_id)
      end
    end
  end
end
