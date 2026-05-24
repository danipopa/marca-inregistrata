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

ActiveRecord::Schema[8.1].define(version: 2026_05_23_131000) do
  create_table "trademark_requests", force: :cascade do |t|
    t.text "address"
    t.integer "classes_count", default: 1, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "RON", null: false
    t.string "email", null: false
    t.text "goods"
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
    t.string "product_name", default: "Marca verbala", null: false
    t.string "status", default: "new", null: false
    t.string "tax_id"
    t.integer "total_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["created_at"], name: "index_trademark_requests_on_created_at"
    t.index ["email"], name: "index_trademark_requests_on_email"
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

  add_foreign_key "trademark_requests", "users"
end
