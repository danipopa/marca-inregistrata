require "test_helper"
require "base64"

class Api::V1::Admin::ThemeImagesControllerTest < ActionDispatch::IntegrationTest
  test "uploads and lists theme images" do
    admin = User.create_with_password!(email: "admin@example.com", password: "password123")
    admin.update!(admin: true)

    image_file = uploaded_png

    post api_v1_admin_theme_images_url,
      params: {
        theme_image: {
          name: "Homepage hero",
          file: image_file
        }
      },
      headers: { "Authorization" => "Bearer #{issue_mfa_auth_token(admin)}" }

    assert_response :created
    assert_equal "Homepage hero", response.parsed_body.dig("image", "name")
    assert_match(/^theme:\d+$/, response.parsed_body.dig("image", "key"))
    assert_match(%r{/api/v1/theme_images/\d+}, response.parsed_body.dig("image", "url"))

    get api_v1_admin_theme_images_url,
      headers: { "Authorization" => "Bearer #{issue_mfa_auth_token(admin)}" },
      as: :json

    assert_response :success
    assert_equal ["Homepage hero"], response.parsed_body["images"].pluck("name")
  ensure
    image_file&.tempfile&.close!
  end

  private

  def uploaded_png
    file = Tempfile.new([ "theme-image", ".png" ])
    file.binmode
    file.write(Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII="))
    file.rewind

    Rack::Test::UploadedFile.new(file.path, "image/png", original_filename: "theme-image.png")
  end
end
