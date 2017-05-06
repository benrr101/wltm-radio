class CreateSettings < ActiveRecord::Migration
  def change
    # Create table
    create_table :persistent_settings do |t|
      t.string  :key, :null => false
      t.string  :value, :null => false
    end

    # Set key as a unique index
    add_index :persistent_settings, :key, :unique => true
  end
end