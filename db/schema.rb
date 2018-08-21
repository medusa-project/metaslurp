# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_08_21_134728) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

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
    t.string "description"
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
    t.index ["facetable"], name: "index_element_defs_on_facetable"
    t.index ["name"], name: "index_element_defs_on_name", unique: true
    t.index ["searchable"], name: "index_element_defs_on_searchable"
    t.index ["sortable"], name: "index_element_defs_on_sortable"
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

  add_foreign_key "element_mappings", "content_services", on_update: :cascade, on_delete: :cascade
  add_foreign_key "element_mappings", "element_defs", on_update: :cascade, on_delete: :cascade
  add_foreign_key "harvests", "content_services", on_update: :cascade, on_delete: :cascade
  add_foreign_key "harvests", "users", on_update: :cascade, on_delete: :nullify
  add_foreign_key "roles_users", "roles", on_update: :cascade, on_delete: :cascade
  add_foreign_key "roles_users", "users", on_update: :cascade, on_delete: :cascade
end
