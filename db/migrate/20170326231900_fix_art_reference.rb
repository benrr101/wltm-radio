class FixArtReference < ActiveRecord::Migration
  def change
    Track.find_each(batch_size: 100) do |track|
      unless track.art_id.nil?
        next
      end

      art = Art.create_from_file(track.absolute_path)
      unless art.id.nil?
        next
      end
      track.update_attributes(:art_id => art.id)
    end
  end
end