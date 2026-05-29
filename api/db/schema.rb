# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_28_172000) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cookie_consents", force: :cascade do |t|
    t.boolean "accepted", default: true, null: false
    t.datetime "accepted_at", null: false
    t.string "consent_id", null: false
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.text "user_agent"
    t.string "version", null: false
    t.index ["accepted_at"], name: "index_cookie_consents_on_accepted_at"
    t.index ["consent_id"], name: "index_cookie_consents_on_consent_id", unique: true
  end

  create_table "product_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_product_images_on_name"
  end

  create_table "site_themes", force: :cascade do |t|
    t.string "background_color", default: "#ffffff", null: false
    t.string "brand_color", default: "#013ebe", null: false
    t.string "brand_name", default: "SANDU și Asociații IP Attorney", null: false
    t.datetime "created_at", null: false
    t.string "font_family", default: "Montserrat", null: false
    t.text "footer_text"
    t.string "hero_image_key"
    t.string "line_color", default: "#ded8cf", null: false
    t.string "logo_image_key"
    t.string "muted_color", default: "#68635c", null: false
    t.string "primary_color", default: "#00add9", null: false
    t.string "primary_dark_color", default: "#00add9", null: false
    t.text "privacy_policy_content"
    t.text "terms_content"
    t.string "text_color", default: "#1f1d1a", null: false
    t.datetime "updated_at", null: false
  end

  create_table "theme_images", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_theme_images_on_name"
  end

  create_table "trademark_products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "base_price_lei", default: 0, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "RON", null: false
    t.string "image_key"
    t.text "items_en", null: false
    t.text "items_ro", null: false
    t.string "note_en", default: "", null: false
    t.string "note_ro", default: "", null: false
    t.integer "position", default: 0, null: false
    t.string "price_label", null: false
    t.string "region", default: "OSIM", null: false
    t.string "tax_en", default: "includes VAT", null: false
    t.string "tax_ro", default: "include TVA", null: false
    t.string "title_en", null: false
    t.string "title_ro", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "position"], name: "index_trademark_products_on_active_and_position"
    t.index ["code"], name: "index_trademark_products_on_code", unique: true
  end

  create_table "trademark_requests", force: :cascade do |t|
    t.text "address"
    t.text "admin_comments", null: false
    t.integer "classes_count", default: 1, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "RON", null: false
    t.string "email", null: false
    t.text "goods"
    t.string "ip_address"
    t.string "mark", null: false
    t.string "owner_name"
    t.string "owner_type"
    t.text "payment_checkout_url"
    t.string "payment_method"
    t.string "payment_provider"
    t.string "payment_provider_id"
    t.string "phone", null: false
    t.string "primary_class"
    t.string "product_code", default: "ro-word", null: false
    t.string "product_name", default: "Marca verbala OSIM", null: false
    t.string "status", default: "new", null: false
    t.string "tax_id"
    t.integer "total_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["created_at"], name: "index_trademark_requests_on_created_at"
    t.index ["email"], name: "index_trademark_requests_on_email"
    t.index ["ip_address"], name: "index_trademark_requests_on_ip_address"
    t.index ["payment_provider"], name: "index_trademark_requests_on_payment_provider"
    t.index ["payment_provider_id"], name: "index_trademark_requests_on_payment_provider_id"
    t.index ["product_code"], name: "index_trademark_requests_on_product_code"
    t.index ["status"], name: "index_trademark_requests_on_status"
    t.index ["user_id"], name: "index_trademark_requests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "address"
    t.boolean "admin", default: false, null: false
    t.datetime "auth_token_created_at"
    t.string "auth_token_digest"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "google_sub"
    t.string "name"
    t.string "owner_name"
    t.string "owner_type"
    t.string "password_digest", null: false
    t.string "password_salt", null: false
    t.string "phone"
    t.string "tax_id"
    t.datetime "updated_at", null: false
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["auth_token_digest"], name: "index_users_on_auth_token_digest", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_sub"], name: "index_users_on_google_sub", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "trademark_requests", "users"
end
