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

ActiveRecord::Schema.define(version: 20161116113200) do

  create_table "buffer_records", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "absolute_path"
    t.string   "on_behalf_of"
    t.boolean  "bot_queued"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "history_records", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "on_behalf_of"
    t.boolean  "bot_queued"
    t.datetime "played_time"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "track_id"
    t.index ["track_id"], name: "index_history_records_on_track_id", using: :btree
  end

  create_table "tracks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "absolute_path", null: false
    t.string   "artist"
    t.string   "album"
    t.string   "title"
    t.string   "uploader"
    t.integer  "length"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["absolute_path"], name: "index_tracks_on_absolute_path", unique: true, using: :btree
  end

  add_foreign_key "history_records", "tracks"
end
