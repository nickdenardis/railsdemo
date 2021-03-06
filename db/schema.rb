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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121222231614) do

  create_table "sites", :force => true do |t|
    t.string   "url"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "is_ssl",     :default => false
    t.string   "domain"
    t.string   "uri"
    t.integer  "user_id"
  end

  create_table "snapshots", :force => true do |t|
    t.integer  "site_id"
    t.string   "title"
    t.text     "raw_html"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "filename"
    t.string   "public_url"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
