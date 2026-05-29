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
end
