require 'rufus-scheduler'
require 'active_support/time'

############################################################################
# Player Enqueue Task
# - This task will run every 5 seconds and check to see 1) how many tracks are currently enqueued
#   in MPD, and 2) is the current track has less than 10 seconds remaining. If the conditions are
#   met, a track from the buffer will be removed and added to the queue.
Rails.application.config.after_initialize do
  # Only define the task if we're in a server environment with MPD enabled
  unless (defined?(Rails::Server) || defined?(ENV['server_mode'])) && Rails.configuration.mpd['enable']
    Rails.logger.warn('Player task will not be enabled, this is not a server environment, or MPD support is disabled')
    next
  end

  # Grab the singleton instance of the Rufus scheduler
  s = Rufus::Scheduler.singleton

  # Setup the task to run every 5 seconds
  s.every '5s', overlap: false do
    # If there is less than one track in the queue or if the remaining time is less than
    # 10 seconds, add another one from the buffer
    mpd = Mpd.new
    remaining_time = mpd.remaining_time
    if mpd.queue_length < 2 && (remaining_time.nil? || remaining_time <= 10)
      # Pop the top of the buffer
      buffer_file = BufferRecord.first
      if buffer_file.nil?
        Rails.logger.error('Buffer is empty! Cannot add to mpd queue! Consider increasing size of buffer to prevent mpd starvation')
        next
      end
      buffer_file.destroy

      # Add it to MPD's queue
      begin
        Rails.logger.info("Adding to MPD playlist: #{File.basename(buffer_file.absolute_path)}")
        file_uri = "file:///#{buffer_file.absolute_path}"
        mpd.queue_add(file_uri)
      rescue Exception => e
        Rails.logger.error("Failed to add '#{file_uri}' to MPD: #{e.message}")
        next
      end

      # Add the track to the track table if it isn't already in there
      track_record = Track.find_or_create_by!(absolute_path: buffer_file.absolute_path) do |track|
        # Pull the information about the track out of the file
        track_info = AudioInfo.new(buffer_file.absolute_path)
        track.artist = track_info.artist || 'Unknown Artist'
        track.album = track_info.album || 'Unknown Album'
        track.title = track_info.title || 'Unknown Title',
        track.uploader = FileSystem::get_track_uploader(buffer_file.absolute_path)
        track.length = track_info.length.round(0)
      end

      HistoryRecord.create(
         on_behalf_of: buffer_file.on_behalf_of,
         bot_queued: buffer_file.bot_queued,
         played_time: DateTime.now + remaining_time.seconds,
         track_id: track_record.id
      )
    else
      Rails.logger.debug("Current track has #{remaining_time}s left and #{mpd.queue_length} track in queue, no tracks will be added to queue")
    end
  end
end
