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

ActiveRecord::Schema.define(version: 2024_12_01_173553) do

  create_table "actions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "problem"
    t.string "action"
    t.string "channel"
  end

# Could not dump table "answers" because of following StandardError
#   Unknown type 'bool' for column 'hide_reason'

  create_table "bitbucket_commits", force: :cascade do |t|
    t.string "commit_id"
    t.string "author"
    t.text "message"
    t.datetime "date"
    t.string "project_key"
    t.string "repo_slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_key", "repo_slug", "commit_id"], name: "index_bitbucket_commits_on_project_repo_commit", unique: true
  end

  create_table "channels", id: false, force: :cascade do |t|
    t.string "slack_channel_id"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "reminder_enabled", default: false
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

  create_table "labels", force: :cascade do |t|
    t.string "label", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string "message_id", null: false
    t.string "ts"
    t.string "thread_ts"
    t.string "event_ts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "reply_counter"
    t.integer "#<ActiveRecord::ConnectionAdapters::SQLite3::TableDefinition:0x00000001265751f8>"
    t.boolean "remind_needed"
    t.string "channel_id"
  end

  create_table "slack_thread_labels", force: :cascade do |t|
    t.integer "slack_thread_id", null: false
    t.integer "label_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["label_id"], name: "index_slack_thread_labels_on_label_id"
    t.index ["slack_thread_id"], name: "index_slack_thread_labels_on_slack_thread_id"
  end

  create_table "slack_threads", force: :cascade do |t|
    t.string "thread_ts"
    t.string "channel_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

  add_foreign_key "slack_thread_labels", "labels"
  add_foreign_key "slack_thread_labels", "slack_threads"
end
