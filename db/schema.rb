# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_14_204809) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "boosts", force: :cascade do |t|
    t.string "field", null: false
    t.string "value", null: false
    t.integer "boost", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field", "value"], name: "index_boosts_on_field_and_value", unique: true
  end

  create_table "content_services", force: :cascade do |t|
    t.string "name", null: false
    t.string "key", null: false
    t.string "uri"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_content_services_on_key", unique: true
    t.index ["name"], name: "index_content_services_on_name", unique: true
  end

  create_table "element_defs", force: :cascade do |t|
    t.string "name"
    t.string "label"
    t.string "description"
    t.boolean "searchable", default: true
    t.boolean "sortable", default: true
    t.boolean "facetable", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "data_type", null: false
    t.integer "weight", default: 0, null: false
    t.index ["facetable"], name: "index_element_defs_on_facetable"
    t.index ["name"], name: "index_element_defs_on_name", unique: true
    t.index ["searchable"], name: "index_element_defs_on_searchable"
    t.index ["sortable"], name: "index_element_defs_on_sortable"
    t.index ["weight"], name: "index_element_defs_on_weight"
  end

  create_table "element_mappings", force: :cascade do |t|
    t.bigint "content_service_id"
    t.string "source_name"
    t.bigint "element_def_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_service_id", "source_name"], name: "index_element_mappings_on_content_service_id_and_source_name", unique: true
  end

  create_table "harvests", force: :cascade do |t|
    t.bigint "content_service_id", null: false
    t.string "key", null: false
    t.integer "status", default: 0, null: false
    t.integer "num_items", default: 0, null: false
    t.integer "num_succeeded", default: 0, null: false
    t.integer "num_failed", default: 0, null: false
    t.datetime "ended_at"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "incremental", default: false, null: false
    t.string "ecs_task_uuid"
    t.integer "max_num_items"
    t.index ["created_at"], name: "index_harvests_on_created_at"
    t.index ["key"], name: "index_harvests_on_key", unique: true
    t.index ["status"], name: "index_harvests_on_status"
  end

  create_table "options", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_options_on_key"
  end

  create_table "roles", force: :cascade do |t|
    t.string "key"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_roles_on_key"
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "user_id", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_key"
    t.boolean "human", default: true
    t.index ["username"], name: "index_users_on_username"
  end

  create_table "value_mappings", force: :cascade do |t|
    t.string "source_value"
    t.string "local_value"
    t.bigint "element_def_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["element_def_id", "source_value"], name: "index_value_mappings_on_element_def_id_and_source_value", unique: true
  end

  add_foreign_key "element_mappings", "content_services", on_update: :cascade, on_delete: :cascade
  add_foreign_key "element_mappings", "element_defs", on_update: :cascade, on_delete: :cascade
  add_foreign_key "harvests", "content_services", on_update: :cascade, on_delete: :cascade
  add_foreign_key "harvests", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "roles_users", "roles", on_update: :cascade, on_delete: :cascade
  add_foreign_key "roles_users", "users", on_update: :cascade, on_delete: :cascade
  add_foreign_key "value_mappings", "element_defs", on_update: :cascade, on_delete: :cascade
end
