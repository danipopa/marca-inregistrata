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

ActiveRecord::Schema[8.1].define(version: 2026_05_12_233424) do
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
    t.string "payment_method"
    t.string "phone", null: false
    t.string "primary_class"
    t.string "status", default: "new", null: false
    t.string "tax_id"
    t.integer "total_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_trademark_requests_on_email"
    t.index ["status"], name: "index_trademark_requests_on_status"
  end
end
