class CreateArt < ActiveRecord::Migration[5.0]
  def change
    # Create a table for storing artwork
    create_table :art do |t|
      t.string :hash, :null => false, limit: 64
      t.binary :artwork, :null => false

      t.timestamps
    end

    add_index :art, :hash, :unique => true

    # Create reference from track -> art table
    add_reference :tracks, :art, index: true
    add_foreign_key :tracks, :art
  end
end