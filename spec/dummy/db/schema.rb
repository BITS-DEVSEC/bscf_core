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

ActiveRecord::Schema[8.0].define(version: 2025_03_26_081052) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bscf_core_addresses", force: :cascade do |t|
    t.string "city"
    t.string "sub_city"
    t.string "woreda"
    t.string "latitude"
    t.string "longitude"
    t.string "house_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bscf_core_roles", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bscf_core_user_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "date_of_birth", null: false
    t.string "nationality", null: false
    t.string "occupation", null: false
    t.string "source_of_funds", null: false
    t.integer "kyc_status", default: 0
    t.integer "gender", null: false
    t.datetime "verified_at"
    t.bigint "verified_by_id"
    t.bigint "address_id", null: false
    t.string "fayda_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "address_id" ], name: "index_bscf_core_user_profiles_on_address_id"
    t.index [ "user_id" ], name: "index_bscf_core_user_profiles_on_user_id"
    t.index [ "verified_by_id" ], name: "index_bscf_core_user_profiles_on_verified_by_id"
  end

  create_table "bscf_core_users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "middle_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "phone_number", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "email" ], name: "index_bscf_core_users_on_email", unique: true
    t.index [ "phone_number" ], name: "index_bscf_core_users_on_phone_number", unique: true
  end

  add_foreign_key "bscf_core_user_profiles", "bscf_core_addresses", column: "address_id"
  add_foreign_key "bscf_core_user_profiles", "bscf_core_users", column: "user_id"
  add_foreign_key "bscf_core_user_profiles", "bscf_core_users", column: "verified_by_id"
end
