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

ActiveRecord::Schema.define(version: 20170326220000) do

  create_table "arts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "hash_code",  limit: 64,       null: false
    t.string   "mimetype",   limit: 128,      null: false
    t.binary   "bytes",      limit: 16777215, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["hash_code"], name: "index_arts_on_hash_code", unique: true, using: :btree
  end

  create_table "buffer_records", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "on_behalf_of"
    t.boolean  "bot_queued"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "track_id"
    t.index ["track_id"], name: "index_buffer_records_on_track_id", using: :btree
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

  create_table "hmac_keys", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "public_key",  limit: 36, null: false
    t.string "private_key", limit: 36, null: false
    t.string "description"
    t.index ["private_key"], name: "index_hmac_keys_on_private_key", unique: true, using: :btree
    t.index ["public_key"], name: "index_hmac_keys_on_public_key", unique: true, using: :btree
  end

  create_table "skips", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "on_behalf_of"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "history_record_id"
    t.index ["history_record_id"], name: "index_skips_on_history_record_id", using: :btree
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
    t.integer  "art_id"
    t.index ["absolute_path"], name: "index_tracks_on_absolute_path", unique: true, using: :btree
    t.index ["art_id"], name: "index_tracks_on_art_id", using: :btree
  end

  add_foreign_key "buffer_records", "tracks"
  add_foreign_key "history_records", "tracks"
  add_foreign_key "skips", "history_records"
  add_foreign_key "tracks", "arts"
end
