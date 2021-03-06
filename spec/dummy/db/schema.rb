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

ActiveRecord::Schema.define(version: 20171108113259) do

  create_table "maily_herald_dispatches", force: :cascade do |t|
    t.string "type", null: false
    t.integer "sequence_id"
    t.integer "list_id", null: false
    t.text "conditions"
    t.text "start_at"
    t.string "mailer_name"
    t.string "name", null: false
    t.string "title"
    t.string "subject"
    t.string "from"
    t.string "state", default: "disabled"
    t.text "template_plain"
    t.integer "absolute_delay"
    t.integer "period"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "kind", default: 0, null: false
    t.text "template_html"
    t.boolean "track", default: true
    t.index ["name"], name: "index_maily_herald_dispatches_on_name", unique: true
  end

  create_table "maily_herald_lists", force: :cascade do |t|
    t.string "name", null: false
    t.string "title"
    t.string "context_name"
  end

  create_table "maily_herald_logs", force: :cascade do |t|
    t.integer "entity_id", null: false
    t.string "entity_type", null: false
    t.string "entity_email"
    t.integer "mailing_id"
    t.string "status", null: false
    t.text "data"
    t.datetime "processing_at"
    t.string "token"
  end

  create_table "maily_herald_subscriptions", force: :cascade do |t|
    t.integer "entity_id", null: false
    t.integer "list_id", null: false
    t.string "entity_type", null: false
    t.string "token", null: false
    t.text "settings"
    t.text "data"
    t.boolean "active", default: false, null: false
    t.datetime "delivered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.boolean "weekly_notifications", default: true
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
