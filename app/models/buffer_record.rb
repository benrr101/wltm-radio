class BufferRecord < ApplicationRecord
  belongs_to :track

  # Adds all tracks in the list to the buffer on behalf of the requestor. Performs all the logic
  # for removing bot queued entries and inserts after unique requests
  # @param [Array<Track>] folder_items List of tracks to add to the buffer
  # @param [String] on_behalf_of The user that requested the tracks
  # @return [Integer] Number of seconds before requested tracks will be played
  def self.add_request(folder_items, on_behalf_of)
    # Take what remains and iterate over it
    seconds_remaining = 0
    requestors_seen = {}
    folders_seen = {}
    records_to_readd = []
    BufferRecord.joins(:track).each do |buffer|
      # If it's bot queued, leave it. We'll clean it out later
      if buffer.bot_queued?
        next
      end

      # If we haven't seen this requester, keep it in the buffer
      folder = File.dirname(buffer.track.absolute_path)
      if requestors_seen[buffer.on_behalf_of].nil?
        requestors_seen[buffer.on_behalf_of] = 1
        folders_seen[folder] = 1
        seconds_remaining += buffer.track.length
        next
      end

      # We have seen this requester before
      # If we have seen the folder before, keep it in the buffer
      unless folders_seen[folder].nil?
        seconds_remaining += buffer.track.length
        next
      end

      # We haven't seen this folder before.
      # Therefore this is the second request from the user
      # We will play this request before the user's second request
      records_to_readd.push(buffer)
    end

    # Add all the files that were requested
    folder_items.each do |item|
      BufferRecord.create(on_behalf_of: on_behalf_of,
                          bot_queued: false,
                          track_id: item.id)
      Rails.logger.info("Added track #{item.artist} - #{item.title} on behalf of #{on_behalf_of}")
    end

    # All the records that need to be added again will be created at the end of the queue and
    # then deleted from their original positions
    records_to_readd.each do |record|
      BufferRecord.create(on_behalf_of: record.on_behalf_of,
                          bot_queued: false,
                          track_id: record.track_id)
      record.destroy
      Rails.logger.info("Shifted request from #{record.on_behalf_of} to end of buffer")
    end

    # Clean out the bot records
    BufferRecord.destroy_all({bot_queued: true})

    return {
        seconds_remaining: seconds_remaining,
        tracks_enqueued: folder_items.size
    }
  end
end
