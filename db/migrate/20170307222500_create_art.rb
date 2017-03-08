class CreateArt < ActiveRecord::Migration
  def change
    # Create a new table for storing art
    create_table :art do |table|
      table.string  :hash, :null => false, limit: 64
      table.string  :mimetype, :null => false, limit: 128
      table.binary  :bytes, :null => false

    end
  end
end