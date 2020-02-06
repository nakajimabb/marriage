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

ActiveRecord::Schema.define(version: 2019_12_10_053541) do

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

  create_table "answer_choices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "user_id", null: false
    t.bigint "question_choice_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_choice_id"], name: "index_answer_choices_on_question_choice_id"
    t.index ["question_id"], name: "index_answer_choices_on_question_id"
    t.index ["user_id"], name: "index_answer_choices_on_user_id"
  end

  create_table "answer_notes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "user_id", null: false
    t.string "note"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_id"], name: "index_answer_notes_on_question_id"
    t.index ["user_id"], name: "index_answer_notes_on_user_id"
  end

  create_table "eval_partners", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "partner_id", null: false
    t.integer "requirement_score", limit: 1, default: 0, null: false, unsigned: true
    t.boolean "permitted", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_id"], name: "index_eval_partners_on_partner_id"
    t.index ["user_id", "partner_id"], name: "index_eval_partners_on_user_id_and_partner_id", unique: true
    t.index ["user_id"], name: "index_eval_partners_on_user_id"
  end

  create_table "question_choices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.string "label"
    t.integer "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_id"], name: "index_question_choices_on_question_id"
  end

  create_table "questions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "question_type", limit: 1, null: false, unsigned: true
    t.integer "answer_type", limit: 1, null: false, unsigned: true
    t.text "content", null: false
    t.integer "min_answer_size", limit: 1, default: 1, null: false, unsigned: true
    t.integer "max_answer_size", limit: 1, default: 1, null: false, unsigned: true
    t.integer "rank", null: false
    t.bigint "created_by_id", null: false
    t.bigint "updated_by_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_by_id"], name: "index_questions_on_created_by_id"
    t.index ["updated_by_id"], name: "index_questions_on_updated_by_id"
  end

  create_table "requirements", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "min_age", limit: 1, unsigned: true
    t.integer "max_age", limit: 1, unsigned: true
    t.boolean "required_age", default: false, null: false
    t.integer "religion", limit: 1
    t.boolean "required_religion", default: false, null: false
    t.integer "marital_status", limit: 1
    t.boolean "required_marital_status", default: false, null: false
    t.integer "min_income"
    t.integer "max_income"
    t.boolean "required_income", default: false, null: false
    t.integer "min_height", limit: 1, unsigned: true
    t.integer "max_height", limit: 1, unsigned: true
    t.boolean "required_height", default: false, null: false
    t.bigint "created_by_id", null: false
    t.bigint "updated_by_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_by_id"], name: "index_requirements_on_created_by_id"
    t.index ["updated_by_id"], name: "index_requirements_on_updated_by_id"
    t.index ["user_id"], name: "index_requirements_on_user_id", unique: true
  end

  create_table "room_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["room_id", "user_id"], name: "index_room_users_on_room_id_and_user_id", unique: true
    t.index ["room_id"], name: "index_room_users_on_room_id"
    t.index ["user_id"], name: "index_room_users_on_user_id"
  end

  create_table "rooms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "room_type"
    t.date "dated_on", null: false
    t.date "fixed_on", null: false
    t.string "name"
    t.text "remark"
    t.integer "prefecture", limit: 2
    t.string "address"
    t.bigint "user_id", null: false
    t.integer "min_age", limit: 1, unsigned: true
    t.integer "max_age", limit: 1, unsigned: true
    t.integer "male_count", limit: 1, null: false, unsigned: true
    t.integer "female_count", limit: 1, null: false, unsigned: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_rooms_on_user_id"
  end

  create_table "user_friends", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "companion_id", null: false
    t.integer "status", limit: 1, default: 1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["companion_id"], name: "index_user_friends_on_companion_id"
    t.index ["user_id", "companion_id"], name: "index_user_friends_on_user_id_and_companion_id", unique: true
    t.index ["user_id"], name: "index_user_friends_on_user_id"
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
    t.string "nickname", null: false
    t.string "email", null: false
    t.text "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", limit: 1, default: 1, null: false, unsigned: true
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
    t.string "street", limit: 64
    t.string "building", limit: 64
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
    t.text "remark_self"
    t.text "remark_matchmaker"
    t.integer "member_sharing", limit: 1, default: 1, null: false
    t.bigint "matchmaker_id"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["created_by_id"], name: "index_users_on_created_by_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["matchmaker_id"], name: "index_users_on_matchmaker_id"
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
    t.index ["updated_by_id"], name: "index_users_on_updated_by_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "answer_choices", "question_choices"
  add_foreign_key "answer_choices", "questions"
  add_foreign_key "answer_choices", "users"
  add_foreign_key "answer_notes", "questions"
  add_foreign_key "answer_notes", "users"
  add_foreign_key "eval_partners", "users"
  add_foreign_key "eval_partners", "users", column: "partner_id"
  add_foreign_key "question_choices", "questions"
  add_foreign_key "questions", "users", column: "created_by_id"
  add_foreign_key "questions", "users", column: "updated_by_id"
  add_foreign_key "requirements", "users"
  add_foreign_key "requirements", "users", column: "created_by_id"
  add_foreign_key "requirements", "users", column: "updated_by_id"
  add_foreign_key "room_users", "rooms"
  add_foreign_key "room_users", "users"
  add_foreign_key "rooms", "users"
  add_foreign_key "user_friends", "users"
  add_foreign_key "user_friends", "users", column: "companion_id"
  add_foreign_key "users", "users", column: "created_by_id"
  add_foreign_key "users", "users", column: "matchmaker_id"
  add_foreign_key "users", "users", column: "updated_by_id"
end
