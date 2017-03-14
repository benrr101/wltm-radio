class CreateArt < ActiveRecord::Migration
  def change
    # Create a new table for storing art
    create_table :arts do |table|
      table.string  :hash_code, :null => false, limit: 64
      table.string  :mimetype, :null => false, limit: 128
      table.binary  :bytes, :null => false

      table.timestamps
    end

    add_index :arts, :hash_code, :unique => true

    # Create a reference between art and track
    add_reference :tracks, :art, index: true
    add_foreign_key :tracks, :arts

    # Iterate over the tracks and store the art for each track
    Track.all.each do |track|
      begin
        art = Art.create_from_file(track.absolute_path)
        unless art.nil?
          track.update_attribute(:art_id, art.id)
          say("Found artwork for #{track.absolute_path}", :subitem)
        end
      rescue
        say("Failed to find artwork for #{track.absolute_path}", :subitem)
      end
    end
  end
end