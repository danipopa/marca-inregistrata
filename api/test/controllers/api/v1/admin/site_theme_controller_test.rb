require "test_helper"

class Api::V1::Admin::SiteThemeControllerTest < ActionDispatch::IntegrationTest
  test "updates website theme" do
    admin = User.create_with_password!(email: "admin@example.com", password: "password123")
    admin.update!(admin: true)
    theme_image = ThemeImage.new(name: "Hero")
    theme_image.file.attach(
      io: StringIO.new("image-bytes"),
      filename: "hero.png",
      content_type: "image/png"
    )
    theme_image.save!
    logo_image = ThemeImage.new(name: "Logo")
    logo_image.file.attach(
      io: StringIO.new("logo-bytes"),
      filename: "logo.png",
      content_type: "image/png"
    )
    logo_image.save!

    patch api_v1_admin_site_theme_url,
      params: {
        theme: {
          primary_color: "#123456",
          primary_dark_color: "#234567",
          brand_color: "#345678",
          text_color: "#111111",
          muted_color: "#666666",
          line_color: "#dddddd",
          background_color: "#ffffff",
          font_family: "Inter",
          brand_name: "Custom Brand",
          hero_image_key: theme_image.image_key,
          logo_image_key: logo_image.image_key,
          footer_text: "Footer custom text",
          terms_content: "# Terms\n\nCustom terms",
          privacy_policy_content: "# Privacy\n\nCustom privacy"
        }
      },
      headers: { "Authorization" => "Bearer #{admin.issue_auth_token!}" },
      as: :json

    assert_response :success
    assert_equal "#123456", response.parsed_body.dig("theme", "primary_color")
    assert_equal "Custom Brand", response.parsed_body.dig("theme", "brand_name")
    assert_equal theme_image.image_key, response.parsed_body.dig("theme", "hero_image_key")
    assert_match(%r{/api/v1/theme_images/#{theme_image.id}}, response.parsed_body.dig("theme", "hero_image"))
    assert_equal logo_image.image_key, response.parsed_body.dig("theme", "logo_image_key")
    assert_match(%r{/api/v1/theme_images/#{logo_image.id}}, response.parsed_body.dig("theme", "logo_image"))
    assert_equal "Footer custom text", response.parsed_body.dig("theme", "footer_text")
    assert_equal "# Terms\n\nCustom terms", response.parsed_body.dig("theme", "terms_content")
    assert_equal "# Privacy\n\nCustom privacy", response.parsed_body.dig("theme", "privacy_policy_content")
    assert_equal "Inter", SiteTheme.current.font_family
  end

  test "shows public website theme" do
    SiteTheme.current.update!(font_family: "Lora", brand_color: "#112233")

    get api_v1_site_theme_url, as: :json

    assert_response :success
    assert_equal "Lora", response.parsed_body.dig("theme", "font_family")
    assert_equal "#112233", response.parsed_body.dig("theme", "brand_color")
    assert_equal SiteTheme::DEFAULT_BRAND_NAME, response.parsed_body.dig("theme", "brand_name")
    assert_equal SiteTheme::DEFAULT_FOOTER_TEXT, response.parsed_body.dig("theme", "footer_text")
    assert_equal SiteTheme::DEFAULT_TERMS_CONTENT, response.parsed_body.dig("theme", "terms_content")
    assert_equal SiteTheme::DEFAULT_PRIVACY_POLICY_CONTENT, response.parsed_body.dig("theme", "privacy_policy_content")
  end
end
