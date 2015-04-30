# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140107212721) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: true do |t|
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lists", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "restricted"
    t.integer  "category_id"
    t.integer  "created_by_id"
    t.datetime "last_sent_time"
  end

  add_index "lists", ["category_id"], name: "index_lists_on_category_id", using: :btree
  add_index "lists", ["created_by_id"], name: "index_lists_on_created_by_id", using: :btree

  create_table "lists_users", id: false, force: true do |t|
    t.integer "list_id", null: false
    t.integer "user_id", null: false
  end

  add_index "lists_users", ["list_id", "user_id"], name: "index_lists_users_on_list_id_and_user_id", unique: true, using: :btree

  create_table "subscribers", force: true do |t|
    t.string "email"
  end

  create_table "subscriptions", force: true do |t|
    t.integer "list_id"
    t.integer "subscriber_id"
  end

  add_index "subscriptions", ["list_id"], name: "index_subscriptions_on_list_id", using: :btree
  add_index "subscriptions", ["subscriber_id"], name: "index_subscriptions_on_subscriber_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "subscriber_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["subscriber_id"], name: "index_users_on_subscriber_id", unique: true, using: :btree

end
