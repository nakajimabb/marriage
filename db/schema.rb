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

ActiveRecord::Schema.define(version: 2019_10_02_100459) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "nickname"
    t.string "email"
    t.text "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_name", limit: 64
    t.string "last_name", limit: 64
    t.string "first_name_kana", limit: 64
    t.string "last_name_kana", limit: 64
    t.string "first_name_en", limit: 64
    t.string "last_name_en", limit: 64
    t.integer "sex", limit: 1, null: false
    t.date "birthday"
    t.string "tel", limit: 16
    t.string "mobile", limit: 16
    t.string "fax", limit: 16
    t.integer "lang", limit: 1, unsigned: true
    t.integer "country", limit: 2
    t.string "zip", limit: 10
    t.integer "prefecture", limit: 2
    t.string "city", limit: 64
    t.string "house_number", limit: 64
    t.integer "religion", limit: 1
    t.string "sect", limit: 64
    t.string "church", limit: 64
    t.boolean "baptized"
    t.integer "baptized_year", limit: 2
    t.string "bio"
    t.boolean "role_courtship", default: false, null: false
    t.boolean "role_matchmaker", default: false, null: false
    t.boolean "role_head", default: false, null: false
    t.string "gene_partner_id", limit: 10
    t.integer "income"
    t.integer "drinking", limit: 1
    t.integer "smoking", limit: 1
    t.integer "weight", limit: 1, unsigned: true
    t.integer "height", limit: 1, unsigned: true
    t.string "job", limit: 64
    t.string "education", limit: 64
    t.string "hobby", limit: 64
    t.integer "blood", limit: 1
    t.integer "marital_status", limit: 1
    t.boolean "diseased"
    t.string "disease_name", limit: 64
    t.text "remark"
    t.integer "member_sharing", limit: 1
    t.bigint "matchmaker_id"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["created_by_id"], name: "index_users_on_created_by_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["matchmaker_id"], name: "index_users_on_matchmaker_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
    t.index ["updated_by_id"], name: "index_users_on_updated_by_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "users", "users", column: "created_by_id"
  add_foreign_key "users", "users", column: "matchmaker_id"
  add_foreign_key "users", "users", column: "updated_by_id"
end
