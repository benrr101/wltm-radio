class CreateArt < ActiveRecord::Migration
  def change
    # Create a new table for storing art
    create_table :arts do |table|
      table.string  :hash_code, :null => false, limit: 64
      table.string  :mimetype, :null => false, limit: 128
      table.binary  :bytes, :null => false, limit: 10.megabyte

      table.timestamps
    end

    add_index :arts, :hash_code, :unique => true

    # Create a reference between art and track
    add_reference :tracks, :art, index: true
    add_foreign_key :tracks, :arts

    # Iterate over the tracks and store the art for each track
    Track.find_each(batch_size: 100) do |track|
      unless File.exists?(track.absolute_path)
        say("Pruning #{track.absolute_path}", :subitem)
        track.destroy
      end

      say("Updating #{track.absolute_path}", :subitem)
      begin
        art = Art.create_from_file(track.absolute_path)
        if art.nil?
          say('No artwork found')
        else
          track.update_attributes(:art_id => art.id)
          say('Found artwork!', :subitem)
        end
      rescue => e
        say("Failed to find artwork for #{track.absolute_path} #{e.message}", :subitem)
        say("... #{e.backtrace}", :subitem)
      end
    end
  end
end