# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090225065214) do

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.string   "subtitle"
    t.text     "blurb"
    t.text     "body"
    t.text     "body_html"
    t.string   "status"
    t.datetime "published_at"
    t.integer  "legacy_id"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "redirect_to"
    t.string   "tag"
    t.integer  "parent_page_id"
    t.integer  "legacy_id"
    t.text     "metakeywords"
    t.text     "metadescription"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "placements", :force => true do |t|
    t.integer  "article_id"
    t.integer  "page_id"
    t.integer  "list_order"
    t.string   "display"
    t.boolean  "canonical"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "child_page_id"
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "landing_page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "perishable_token"
    t.integer  "login_count"
    t.integer  "failed_login_count"
    t.integer  "legacy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
