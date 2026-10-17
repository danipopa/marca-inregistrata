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

ActiveRecord::Schema[8.1].define(version: 2026_10_17_120000) do
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

  create_table "monitoring_checks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "error_message"
    t.datetime "finished_at"
    t.integer "monitoring_subscription_id", null: false
    t.integer "new_matches_count", default: 0, null: false
    t.string "provider", null: false
    t.integer "results_count", default: 0, null: false
    t.datetime "started_at", null: false
    t.string "status", default: "running", null: false
    t.datetime "updated_at", null: false
    t.index ["monitoring_subscription_id"], name: "index_monitoring_checks_on_monitoring_subscription_id"
  end

  create_table "monitoring_matches", force: :cascade do |t|
    t.string "application_number"
    t.datetime "created_at", null: false
    t.string "external_id", null: false
    t.datetime "first_seen_at", null: false
    t.string "identity_key", limit: 64, null: false
    t.datetime "last_seen_at", null: false
    t.integer "monitoring_subscription_id", null: false
    t.string "name", null: false
    t.datetime "notified_at"
    t.string "office", null: false
    t.string "registration_number"
    t.string "review_status", default: "pending", null: false
    t.string "source_url", limit: 2048
    t.string "trademark_status"
    t.datetime "updated_at", null: false
    t.index ["monitoring_subscription_id", "identity_key"], name: "index_monitoring_matches_identity", unique: true
    t.index ["monitoring_subscription_id"], name: "index_monitoring_matches_on_monitoring_subscription_id"
  end

  create_table "monitoring_subscriptions", force: :cascade do |t|
    t.datetime "activated_at"
    t.integer "consecutive_failures", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.integer "interval_hours", default: 24, null: false
    t.datetime "last_checked_at"
    t.string "last_error"
    t.datetime "last_report_at"
    t.datetime "last_success_at"
    t.datetime "lease_expires_at"
    t.string "lease_token"
    t.datetime "next_check_at"
    t.datetime "next_report_at"
    t.boolean "notifications_enabled", default: true, null: false
    t.string "registration_number"
    t.string "registration_office"
    t.string "status", default: "pending_activation", null: false
    t.integer "trademark_request_id", null: false
    t.datetime "updated_at", null: false
    t.index ["status", "next_check_at"], name: "index_monitoring_subscriptions_on_status_and_next_check_at"
    t.index ["trademark_request_id"], name: "index_monitoring_subscriptions_on_trademark_request_id", unique: true
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
    t.string "footer_logo_image_key"
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
    t.text "items_en", default: "[]", null: false
    t.text "items_ro", default: "[]", null: false
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

  create_table "trademark_request_events", force: :cascade do |t|
    t.string "action", null: false
    t.integer "admin_user_id"
    t.datetime "created_at", null: false
    t.string "field_name"
    t.text "new_value"
    t.text "old_value"
    t.integer "trademark_request_id", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_trademark_request_events_on_action"
    t.index ["admin_user_id"], name: "index_trademark_request_events_on_admin_user_id"
    t.index ["created_at"], name: "index_trademark_request_events_on_created_at"
    t.index ["trademark_request_id"], name: "index_trademark_request_events_on_trademark_request_id"
  end

  create_table "trademark_requests", force: :cascade do |t|
    t.text "address"
    t.text "admin_comments", default: "", null: false
    t.integer "classes_count", default: 1, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "RON", null: false
    t.string "email", null: false
    t.text "goods"
    t.string "ip_address"
    t.string "mark", null: false
    t.string "order_type", default: "registration", null: false
    t.boolean "owner_change_requested", default: false, null: false
    t.string "owner_name"
    t.string "owner_type"
    t.text "payment_checkout_url"
    t.string "payment_method"
    t.string "payment_provider"
    t.string "payment_provider_id"
    t.string "phone", null: false
    t.string "primary_class"
    t.string "product_code", default: "ro-word", null: false
    t.string "product_name", default: "Marca verbala", null: false
    t.string "registration_number"
    t.string "registration_office"
    t.datetime "removed_from_account_at"
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
    t.index ["removed_from_account_at"], name: "index_trademark_requests_on_removed_from_account_at"
    t.index ["status"], name: "index_trademark_requests_on_status"
    t.index ["user_id"], name: "index_trademark_requests_on_user_id"
  end

  create_table "traffic_page_views", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "path", limit: 100, null: false
    t.string "referrer_host", limit: 255
    t.string "session_key", limit: 64, null: false
    t.string "visitor_key", limit: 64, null: false
    t.index ["created_at"], name: "index_traffic_page_views_on_created_at"
    t.index ["visitor_key", "created_at"], name: "index_traffic_page_views_on_visitor_key_and_created_at"
  end

  create_table "traffic_request_metrics", force: :cascade do |t|
    t.bigint "duration_ms_max", default: 0, null: false
    t.bigint "duration_ms_total", default: 0, null: false
    t.string "endpoint", limit: 180, null: false
    t.datetime "hour", null: false
    t.bigint "requests_count", default: 0, null: false
    t.integer "status", null: false
    t.index ["hour", "endpoint", "status"], name: "index_traffic_request_bucket", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.text "address"
    t.boolean "admin", default: false, null: false
    t.datetime "auth_token_created_at"
    t.string "auth_token_digest"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "google_sub"
    t.datetime "mfa_challenge_created_at"
    t.string "mfa_challenge_digest"
    t.integer "mfa_failed_attempts", default: 0, null: false
    t.datetime "mfa_locked_until"
    t.string "name"
    t.datetime "otp_enabled_at"
    t.string "otp_secret"
    t.string "owner_name"
    t.string "owner_type"
    t.string "password_digest", null: false
    t.datetime "password_reset_sent_at"
    t.string "password_reset_token_digest"
    t.string "password_salt", null: false
    t.string "phone"
    t.text "recovery_codes_digest"
    t.string "tax_id"
    t.datetime "updated_at", null: false
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["auth_token_digest"], name: "index_users_on_auth_token_digest", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_sub"], name: "index_users_on_google_sub", unique: true
    t.index ["mfa_challenge_digest"], name: "index_users_on_mfa_challenge_digest", unique: true
    t.index ["password_reset_token_digest"], name: "index_users_on_password_reset_token_digest", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "monitoring_checks", "monitoring_subscriptions"
  add_foreign_key "monitoring_matches", "monitoring_subscriptions"
  add_foreign_key "monitoring_subscriptions", "trademark_requests"
  add_foreign_key "trademark_request_events", "trademark_requests"
  add_foreign_key "trademark_request_events", "users", column: "admin_user_id"
  add_foreign_key "trademark_requests", "users"
end
