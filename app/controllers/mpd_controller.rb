require 'audioinfo'
require 'active_support/time'

class MpdController < ActionController::Base

  def enqueue_next()
    mpd = Mpd.new

    # Step 1) Get next track from the buffer
    buffer_file = BufferRecord.first
    if buffer_file.nil?
      Rails.logger.error('Buffer is empty! Cannot add to mpd queue! Consider increasing size of buffer to prevent mpd starvation')
      return
    end
    buffer_file.destroy

    # Step 2) Add the track to MPD's queue
    begin
      Rails.logger.info("Adding to MPD playlist: #{File.basename(buffer_file.absolute_path)}")
      file_uri = "file:///#{buffer_file.absolute_path}"
      mpd.queue_add(file_uri)
    rescue Exception => e
      Rails.logger.error("Failed to add '#{File.basename(buffer_file.absolute_path)}' to MPD: #{e.message}")
      return
    end

    # Step 3) Add the record to the track table if it isn't already in there
    track_record = Track.find_or_create_by!(absolute_path: buffer_file.absolute_path) do |track|
      # Pull the information about the track out of the file
      # TODO: Replace this with taglib when I figure out how to run it on windows
      track_info = AudioInfo.new(buffer_file.absolute_path)
      track.artist = track_info.artist || 'Unknown Artist'
      track.album = track_info.album || 'Unknown Album'
      track.title = track_info.title || 'Unknown Title'
      track.uploader = FileSystem::get_track_uploader(buffer_file.absolute)
    end
  end

end