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

ActiveRecord::Schema.define(:version => 20120316190647) do

  create_table "channel", :primary_key => "chanid", :force => true do |t|
    t.string   "channum"
    t.string   "callsign"
    t.string   "name"
    t.boolean  "visible"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "channel", ["channum"], :name => "index_channels_on_channum"
  add_index "channel", ["visible"], :name => "index_channels_on_visible"

  create_table "program", :force => true do |t|
    t.integer  "chanid"
    t.datetime "starttime"
    t.datetime "endtime"
    t.string   "title"
    t.string   "subtitle"
    t.string   "description"
    t.string   "category"
    t.string   "category_type"
    t.date     "airdate"
    t.float    "stars"
    t.boolean  "previouslyshown"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "program", ["chanid"], :name => "index_programs_on_chanid"
  add_index "program", ["endtime"], :name => "index_programs_on_endtime"
  add_index "program", ["starttime"], :name => "index_programs_on_starttime"
  add_index "program", ["title"], :name => "index_programs_on_title"

end
