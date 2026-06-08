require "test_helper"

class Api::V1::Admin::TrademarkProductsControllerTest < ActionDispatch::IntegrationTest
  test "updates product attributes" do
    admin = User.create_with_password!(email: "admin@example.com", password: "password123")
    admin.update!(admin: true)
    product = trademark_products(:ro_word)

    patch api_v1_admin_trademark_product_url(product),
      params: {
        trademark_product: {
          title_ro: product.title_ro,
          title_en: product.title_en,
          code: product.code,
          currency: product.currency,
          region: product.region,
          price_label: product.price_label,
          base_price_lei: product.base_price_lei,
          items_ro: ["onorariu actualizat", "taxe OSIM actualizate"],
          items_en: ["updated fee", "updated OSIM taxes"]
        }
      },
      headers: { "Authorization" => "Bearer #{admin.issue_auth_token!}" },
      as: :json

    assert_response :success
    assert_equal ["onorariu actualizat", "taxe OSIM actualizate"], product.reload.items_ro_list
    assert_equal ["onorariu actualizat", "taxe OSIM actualizate"], response.parsed_body.dig("product", "translations", "ro", "items")
  end

  test "updates product price fields only" do
    admin = User.create_with_password!(email: "admin-price@example.com", password: "password123")
    admin.update!(admin: true)
    product = trademark_products(:monitoring_brand)

    patch api_v1_admin_trademark_product_url(product),
      params: {
        trademark_product: {
          price_label: "800 Lei / an",
          base_price_lei: 800
        }
      },
      headers: { "Authorization" => "Bearer #{admin.issue_auth_token!}" },
      as: :json

    assert_response :success
    assert_equal "800 Lei / an", product.reload.price_label
    assert_equal 800, product.base_price_lei
    assert_equal "800 Lei / an", response.parsed_body.dig("product", "price")
    assert_equal 800, response.parsed_body.dig("product", "base_lei")
  end

  test "serializes uploaded product image url" do
    admin = User.create_with_password!(email: "admin@example.com", password: "password123")
    admin.update!(admin: true)
    product_image = ProductImage.new(name: "Custom logo")
    product_image.file.attach(
      io: StringIO.new("image-bytes"),
      filename: "custom-logo.png",
      content_type: "image/png"
    )
    product_image.save!
    product = trademark_products(:ro_word)
    product.update!(image_key: product_image.image_key)

    get api_v1_admin_trademark_products_url,
      headers: { "Authorization" => "Bearer #{admin.issue_auth_token!}" },
      as: :json

    assert_response :success
    serialized_product = response.parsed_body["products"].find { |item| item["id"] == product.id }
    assert_match(%r{/api/v1/product_images/#{product_image.id}}, serialized_product["image"])
  end
end
