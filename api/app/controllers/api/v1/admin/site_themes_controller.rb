module Api
  module V1
    module Admin
      class SiteThemesController < BaseController
        before_action :authenticate_admin!

        def show
          render json: { theme: serialize_theme(SiteTheme.current) }
        end

        def update
          theme = SiteTheme.current

          if theme.update(site_theme_params)
            render json: { theme: serialize_theme(theme) }
          else
            render json: { errors: theme.errors.to_hash }, status: :unprocessable_entity
          end
        end

        private

        def site_theme_params
          params.require(:theme).permit(
            :primary_color,
            :primary_dark_color,
            :brand_color,
            :text_color,
            :muted_color,
            :line_color,
            :background_color,
            :font_family,
            :brand_name,
            :hero_image_key,
            :logo_image_key,
            :footer_logo_image_key,
            :footer_text,
            :terms_content,
            :privacy_policy_content
          )
        end

        def serialize_theme(theme)
          theme.as_json.merge(
            hero_image: theme_image_url_for(theme.hero_image_key),
            logo_image: theme_image_url_for(theme.logo_image_key),
            footer_logo_image: theme_image_url_for(theme.footer_logo_image_key)
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
end
