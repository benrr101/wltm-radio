require 'active_support/time'

class MpdController < ActionController::Base

  def self.enqueue_next(remaining_time)
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
    track_record = Track.create_from_file(buffer_file.absolute_path)

    # Step 4) Add the history record for the track
    HistoryRecord.create(
      on_behalf_of: buffer_file.on_behalf_of,
      bot_queued: buffer_file.bot_queued,
      played_time: DateTime.now + remaining_time.seconds,
      track_id: track_record.id
    )
  end

  def self.skip
    # Step 1) Clear out anything from the history that is in the future
    HistoryRecord.where('played_time > ?', DateTime.now).delete_all

    # Step 2) Enqueue the next track
    enqueue_next(0)

    # Step 3) Tell MPD to skip ahead to the next one
    mpd = Mpd.new
    mpd.next
  end

end