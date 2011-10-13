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

ActiveRecord::Schema.define(:version => 20111002230859) do

  create_table "odd_roles", :force => true do |t|
    t.string "name"
  end

  create_table "odd_roles_weird_users", :id => false, :force => true do |t|
    t.integer "weird_user_id"
    t.integer "odd_role_id"
  end

  create_table "page_parts", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "page_id"
    t.string   "filter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_roles", :force => true do |t|
    t.integer "page_id"
    t.integer "required_role_id"
    t.integer "excluded_role_id"
  end

  create_table "page_snippets", :force => true do |t|
    t.string   "name"
    t.string   "filter"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_snippets", ["name"], :name => "index_page_snippets_on_name"

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "meta_description"
    t.text     "meta_keywords"
    t.string   "status"
    t.datetime "publish_from"
    t.datetime "publish_to"
    t.integer  "created_by"
    t.string   "permalink"
    t.string   "url"
    t.boolean  "display_in_menu",    :default => true
    t.boolean  "display_in_sitemap", :default => true
    t.string   "menu_css_class"
    t.boolean  "no_link",            :default => false
    t.string   "controller"
    t.string   "action"
    t.string   "layout"
    t.text     "js"
    t.text     "css"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "authorable_type"
    t.integer  "authorable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["controller", "action"], :name => "index_pages_on_controller_and_action"
  add_index "pages", ["permalink"], :name => "index_pages_on_permalink"
  add_index "pages", ["url"], :name => "index_pages_on_url"

  create_table "pages_roles", :id => false, :force => true do |t|
    t.integer "page_id"
    t.integer "role_id"
  end

  create_table "weird_users", :force => true do |t|
    t.string "name"
  end

end
