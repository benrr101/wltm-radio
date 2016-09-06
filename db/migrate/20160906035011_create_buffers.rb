class CreateBuffers < ActiveRecord::Migration[5.0]
  def change
    create_table :buffers do |t|
      t.primary_key, :id
      t.string, :absolute_path
      t.string, :on_behalf_of
      t.boolean :bot_queued

      t.timestamps
    end
  end
end
