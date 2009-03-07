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

ActiveRecord::Schema.define(:version => 20090305185751) do

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
    t.string   "legacy_type",   :limit => 20
  end

  create_table "media", :force => true do |t|
    t.string   "name"
    t.string   "caption"
    t.string   "alt"
    t.date     "media_created_on"
    t.string   "media_type"
    t.integer  "width"
    t.integer  "height"
    t.string   "license"
    t.string   "added_by"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.string   "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_layouts", :force => true do |t|
    t.string   "name"
    t.text     "html"
    t.integer  "legacy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "legacy_type", :limit => 20
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
    t.integer  "page_layout_id"
    t.string   "legacy_type",     :limit => 20
    t.integer  "tree_order"
  end

  create_table "placements", :force => true do |t|
    t.integer  "page_id"
    t.integer  "list_order"
    t.string   "view_type"
    t.boolean  "canonical"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "block"
    t.string   "child_type"
    t.integer  "child_id"
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
