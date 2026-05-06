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

ActiveRecord::Schema[8.1].define(version: 2026_05_06_060004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "event_store_events", force: :cascade do |t|
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.binary "data", null: false
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.binary "metadata", null: false
    t.datetime "valid_at", default: -> { "now()" }
    t.index ["event_id"], name: "index_event_store_events_on_event_id", unique: true
  end

  create_table "event_store_streams", force: :cascade do |t|
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.uuid "event_id", null: false
    t.bigint "position", null: false
    t.string "stream", null: false
    t.index ["event_id"], name: "index_event_store_streams_on_event_id", unique: true
    t.index ["stream", "position"], name: "index_event_store_streams_on_stream_and_position", unique: true
  end

  create_table "event_vote_counts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "downvotes_count", default: 0
    t.string "event_id", null: false
    t.integer "total_votes", default: 0
    t.datetime "updated_at", null: false
    t.integer "upvotes_count", default: 0
    t.index ["event_id"], name: "index_event_vote_counts_on_event_id", unique: true
    t.index ["total_votes"], name: "index_event_vote_counts_on_total_votes"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "downvotes_count", default: 0
    t.datetime "end_date"
    t.string "external_id", null: false
    t.string "image_url"
    t.string "location"
    t.decimal "price", precision: 10, scale: 2
    t.datetime "start_date"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "upvotes_count", default: 0
    t.index ["external_id"], name: "index_events_on_external_id", unique: true
    t.index ["start_date"], name: "index_events_on_start_date"
    t.index ["title"], name: "index_events_on_title"
  end

  create_table "guidelines_approvals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "developer_id", null: false
    t.bigint "request_for_comment_id", null: false
    t.datetime "updated_at", null: false
    t.index ["request_for_comment_id", "developer_id"], name: "index_guidelines_approvals_on_rfc_and_dev", unique: true
    t.index ["request_for_comment_id"], name: "index_guidelines_approvals_on_request_for_comment_id"
  end

  create_table "guidelines_request_for_comments", force: :cascade do |t|
    t.string "author_id", null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "number", null: false
    t.string "tid", null: false
    t.datetime "updated_at", null: false
    t.index ["tid"], name: "index_guidelines_request_for_comments_on_tid", unique: true
  end

  create_table "incoming_webhooks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data", null: false
    t.datetime "handled_at"
    t.text "processing_result"
    t.string "service", null: false
    t.datetime "updated_at", null: false
    t.index ["handled_at"], name: "index_incoming_webhooks_on_handled_at"
    t.index ["service"], name: "index_incoming_webhooks_on_service"
  end

  create_table "number_of_rfc_issued_by_developers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "developer_id", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 0, null: false
    t.index ["developer_id"], name: "index_number_of_rfc_issued_by_developers_on_developer_id", unique: true
  end

  add_foreign_key "guidelines_approvals", "guidelines_request_for_comments", column: "request_for_comment_id"
end
