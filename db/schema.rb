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

ActiveRecord::Schema.define(version: 2021_03_20_231638) do

  create_table "answers", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "channel_id"
  end

  create_table "channels", id: false, force: :cascade do |t|
    t.string "slack_channel_id"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "channel_id"
    t.index ["channel_id"], name: "index_channels_on_channel_id"
    t.index ["slack_channel_id"], name: "index_channels_on_slack_channel_id", unique: true
  end

  create_table "duties", force: :cascade do |t|
    t.datetime "duty_from", null: false
    t.datetime "duty_to", null: false
    t.string "duty_days", default: "1,2,3,4,5"
    t.string "channel_id", null: false
    t.string "user_id", null: false
    t.boolean "enabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "opsgenie_schedule_name"
    t.string "opsgenie_escalation_name"
  end

  create_table "messages", force: :cascade do |t|
    t.string "message_id", null: false
    t.string "ts"
    t.string "thread_ts"
    t.string "event_ts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reply_counter"
    t.integer "#<ActiveRecord::ConnectionAdapters::SQLite3::TableDefinition:0x0000563524093008>"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: false, force: :cascade do |t|
    t.string "slack_user_id"
    t.string "name"
    t.string "real_name"
    t.string "contacts"
    t.string "tz"
    t.integer "tz_offset"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.index ["slack_user_id"], name: "index_users_on_slack_user_id", unique: true
  end

end
