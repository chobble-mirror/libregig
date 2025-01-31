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

ActiveRecord::Schema[8.0].define(version: 2025_01_30_184500) do
  create_table "band_members", force: :cascade do |t|
    t.integer "member_id", null: false
    t.integer "band_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["band_id"], name: "index_band_members_on_band_id"
    t.index ["member_id"], name: "index_band_members_on_member_id"
  end

  create_table "bands", force: :cascade do |t|
    t.text "description", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.index ["name"], name: "index_bands_on_name"
  end

  create_table "bands_audit", force: :cascade do |t|
    t.integer "band_id", null: false
    t.integer "user_id", null: false
    t.string "column_changed", null: false
    t.string "old_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["band_id"], name: "index_bands_audit_on_band_id"
  end

  create_table "confirmation_tokens", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_confirmation_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_confirmation_tokens_on_user_id"
  end

  create_table "event_bands", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "band_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["band_id"], name: "index_event_bands_on_band_id"
    t.index ["event_id", "band_id"], name: "index_event_bands_on_event_id_and_band_id", unique: true
    t.index ["event_id"], name: "index_event_bands_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.text "description", default: "", null: false
    t.datetime "start_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: "", null: false
    t.datetime "end_date", precision: nil
  end

  create_table "events_audit", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "user_id", null: false
    t.string "column_changed", null: false
    t.string "old_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_events_audit_on_event_id"
  end

  create_table "member_skills", force: :cascade do |t|
    t.integer "member_id", null: false
    t.integer "skill_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_member_skills_on_member_id"
    t.index ["skill_id"], name: "index_member_skills_on_skill_id"
  end

  create_table "members", force: :cascade do |t|
    t.text "description", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.index ["name"], name: "index_members_on_name"
  end

  create_table "members_audit", force: :cascade do |t|
    t.integer "member_id", null: false
    t.integer "user_id", null: false
    t.string "column_changed", null: false
    t.string "old_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_members_audit_on_member_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.integer "bestowing_user_id"
    t.integer "user_id", null: false
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "permission_type", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bestowing_user_id"], name: "index_permissions_on_bestowing_user_id"
    t.index ["item_type", "item_id"], name: "index_invitations_on_invitable"
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_mails", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "state", default: 0
    t.string "subject"
    t.string "recipient"
    t.string "template"
    t.json "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_mails_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "name"
    t.string "password_digest"
    t.boolean "confirmed"
    t.integer "user_type", default: 0, null: false
    t.string "time_zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "band_members", "bands"
  add_foreign_key "band_members", "members"
  add_foreign_key "confirmation_tokens", "users"
  add_foreign_key "event_bands", "bands"
  add_foreign_key "event_bands", "events"
  add_foreign_key "member_skills", "members"
  add_foreign_key "member_skills", "skills"
  add_foreign_key "user_mails", "users"
end
