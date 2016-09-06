class CreateHistoryRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :history_records do |t|
      t.string :absolute_path
      t.string :display_name
      t.string :on_behalf_of
      t.boolean :bot_queued
      t.datetime :played_time

      t.timestamps
    end
  end
end
