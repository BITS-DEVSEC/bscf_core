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

ActiveRecord::Schema[8.0].define(version: 2025_03_26_105652) do
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

  create_table "bscf_core_categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", null: false
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bscf_core_products", force: :cascade do |t|
    t.string "sku", null: false
    t.string "name", null: false
    t.string "description", null: false
    t.bigint "category_id", null: false
    t.decimal "base_price", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "category_id" ], name: "index_bscf_core_products_on_category_id"
    t.index [ "sku" ], name: "index_bscf_core_products_on_sku", unique: true
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

  create_table "bscf_core_user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "role_id" ], name: "index_bscf_core_user_roles_on_role_id"
    t.index [ "user_id" ], name: "index_bscf_core_user_roles_on_user_id"
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

  create_table "bscf_core_virtual_accounts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "account_number", null: false
    t.string "cbs_account_number", null: false
    t.decimal "balance", default: "0.0", null: false
    t.decimal "interest_rate", default: "0.0", null: false
    t.integer "interest_type", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.string "branch_code", null: false
    t.string "product_scheme", null: false
    t.string "voucher_type", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "account_number" ], name: "index_bscf_core_virtual_accounts_on_account_number", unique: true
    t.index [ "branch_code" ], name: "index_bscf_core_virtual_accounts_on_branch_code"
    t.index [ "cbs_account_number" ], name: "index_bscf_core_virtual_accounts_on_cbs_account_number", unique: true
    t.index [ "user_id", "account_number" ], name: "index_bscf_core_virtual_accounts_on_user_id_and_account_number"
    t.index [ "user_id" ], name: "index_bscf_core_virtual_accounts_on_user_id"
  end

  add_foreign_key "bscf_core_products", "bscf_core_categories", column: "category_id"
  add_foreign_key "bscf_core_user_profiles", "bscf_core_addresses", column: "address_id"
  add_foreign_key "bscf_core_user_profiles", "bscf_core_users", column: "user_id"
  add_foreign_key "bscf_core_user_profiles", "bscf_core_users", column: "verified_by_id"
  add_foreign_key "bscf_core_user_roles", "bscf_core_roles", column: "role_id"
  add_foreign_key "bscf_core_user_roles", "bscf_core_users", column: "user_id"
  add_foreign_key "bscf_core_virtual_accounts", "bscf_core_users", column: "user_id"
end
