require 'audioinfo'
class CreateTracks < ActiveRecord::Migration

  class HistoryRecord < ActiveRecord::Base
  end

  class Track < ActiveRecord::Base
  end

  def up
    # Create new table for track records
    create_table :tracks do |t|
      t.string  :absolute_path, :null => false
      t.string  :artist
      t.string  :album
      t.string  :title
      t.string  :uploader
      t.integer :length

      t.timestamps
    end
    add_index :tracks, :absolute_path, :unique => true

    # Create reference from history_records -> tracks
    add_reference :history_records, :track, index: true
    add_foreign_key :history_records, :tracks

    # Load the unique history records into the track table
    HistoryRecord.distinct.pluck(:absolute_path).each do |path|
      # Pull the information about the track out of the file
      begin
        track_info = AudioInfo.new(path)
      rescue Exception
        next
      end

      Track.create(
          :absolute_path => path,
          :artist => track_info.artist || 'Unknown Artist',
          :album => track_info.album || 'Unknown Album',
          :title => track_info.title || 'Unknown Title',
          :uploader => FileSystem::get_track_uploader(path),
          :length => track_info.length.round(0)
      )
    end

    # Set track of each history item to the id of the corresponding track
    HistoryRecord.all.each do |record|
      begin
        track_id = Track.find_by!(absolute_path: record.absolute_path)
        record.update_attribute(:track_id, track_id.id)
      rescue
        record.destroy
      end
    end

    # Delete the absolute_path column
    remove_column :history_records, :absolute_path
    remove_column :history_records, :display_name

  end
end