class CreateBufferRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :buffer_records do |t|
      t.string :absolute_path
      t.string :on_behalf_of
      t.boolean :bot_queued

      t.timestamps
    end
  end
end
