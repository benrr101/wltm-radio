class CreateHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :histories do |t|
      t.primary_key, :id
      t.string, :absolute_path
      t.string, :display_name
      t.string, :on_behalf_of
      t.boolean, :bot_queued
      t.datetime :played

      t.timestamps
    end
  end
end
