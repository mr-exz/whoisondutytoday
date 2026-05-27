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

ActiveRecord::Schema[8.1].define(version: 2025_11_21_200907) do
  create_table "actions", force: :cascade do |t|
    t.string "action"
    t.string "channel"
    t.datetime "created_at", precision: nil, null: false
    t.string "problem"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "answers", force: :cascade do |t|
    t.string "answer_type"
    t.text "body"
    t.string "channel_id"
    t.datetime "created_at", precision: nil, null: false
    t.boolean "hide_reason"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "bitbucket_commits", force: :cascade do |t|
    t.string "author"
    t.string "commit_id"
    t.datetime "created_at", null: false
    t.datetime "date", precision: nil
    t.text "message"
    t.string "project_key"
    t.string "repo_slug"
    t.datetime "updated_at", null: false
    t.index ["project_key", "repo_slug", "commit_id"], name: "index_bitbucket_commits_on_project_repo_commit", unique: true
  end

  create_table "channel_prompts", force: :cascade do |t|
    t.string "channel_id", null: false
    t.datetime "created_at", null: false
    t.text "prompt_text", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_channel_prompts_on_channel_id"
  end

  create_table "channels", id: false, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.string "name"
    t.json "settings"
    t.string "slack_channel_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["slack_channel_id"], name: "index_channels_on_slack_channel_id", unique: true
  end

  create_table "duties", force: :cascade do |t|
    t.string "channel_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "duty_days", default: "1,2,3,4,5"
    t.datetime "duty_from", precision: nil, null: false
    t.datetime "duty_to", precision: nil, null: false
    t.boolean "enabled"
    t.string "opsgenie_escalation_name"
    t.string "opsgenie_schedule_name"
    t.datetime "updated_at", precision: nil, null: false
    t.string "user_id", null: false
  end

  create_table "jira_issue_defaults", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "default_fields", default: {}
    t.string "project_key", null: false
    t.datetime "updated_at", null: false
    t.index ["project_key"], name: "index_jira_issue_defaults_on_project_key", unique: true
  end

  create_table "labels", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "label", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer "#<ActiveRecord::ConnectionAdapters::SQLite3::TableDefinition:0x00000001247100a0>"
    t.string "channel_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "event_ts"
    t.string "message_id", null: false
    t.boolean "remind_needed"
    t.integer "reply_counter"
    t.string "thread_ts"
    t.string "ts"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "slack_thread_labels", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "label_id", null: false
    t.integer "slack_thread_id", null: false
    t.datetime "updated_at", null: false
    t.index ["label_id"], name: "index_slack_thread_labels_on_label_id"
    t.index ["slack_thread_id"], name: "index_slack_thread_labels_on_slack_thread_id"
  end

  create_table "slack_threads", force: :cascade do |t|
    t.string "channel_id"
    t.datetime "created_at", null: false
    t.string "thread_ts"
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", id: false, force: :cascade do |t|
    t.string "contacts"
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.string "real_name"
    t.string "slack_user_id"
    t.string "status"
    t.string "tz"
    t.integer "tz_offset"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["slack_user_id"], name: "index_users_on_slack_user_id", unique: true
  end

  add_foreign_key "channel_prompts", "channels", primary_key: "slack_channel_id"
  add_foreign_key "slack_thread_labels", "labels"
  add_foreign_key "slack_thread_labels", "slack_threads"
end
