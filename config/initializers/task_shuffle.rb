require 'rufus-scheduler'
require 'audioinfo'

############################################################################
# Shuffle Enqueue Task
# - This task will enqueue up to the defined number of tracks to the buffer
#   from the included folders. Files are picked at random, without a shuffle
#   playlist being created.

Rails.application.config.after_initialize do
  # Only define the task if we're in a server environment
  unless defined?(Rails::Server) || defined?(ENV['server_name'])
    Rails.logger.warn('Shuffler task will not be enabled since we are not in a server environment')
    next
  end

  # Create the rufus scheduler singleton
  s = Rufus::Scheduler.singleton

  # Setup the task to run every 10s
  s.every '10s', overlap: false do
    # If there are less than 10 files in the buffer, add to to the buffer until its full
    buffer_count = BufferRecord.count
    until buffer_count > Rails.configuration.queues['buffer_max_tracks']

      # Get all the eligible files, shuffle, and pick one
      unshuffled_files = FileSystem.get_all_shuffle_files
      shuffled_files = unshuffled_files.shuffle
      if shuffled_files.count == 0
        Rails.logger.error('Failed to find tracks to add to buffer!')
        return
      end

      # Select the file to add to the buffer
      shuffle_pick = shuffled_files[0]
      files_to_add = [shuffle_pick]

      # If the track is too short, add track before and after it
      if AudioInfo.new(shuffle_pick).length <= Rails.configuration.queues['bookend_threshold']
        Rails.logger.debug("#{shuffle_pick} is too short, adding tracks before and after it")
        [0, 2].each do |i|
          bookend_file = unshuffled_files[unshuffled_files.index(shuffle_pick) + (i - 1)]
          unless bookend_file == nil || File.dirname(bookend_file) != File.dirname(shuffle_pick)
            files_to_add.insert(i, bookend_file)
          end
        end
      end

      # Add all the tracks to the buffer
      Rails.logger.info("Adding #{files_to_add.length} track to buffer: #{files_to_add.map {|file| File.basename(file)}.join(', ')}")
      files_to_add.each do |file|
        Buffer.create(
          absolute_path: file,
          on_behalf_of: 'shuffle',
          bot_queued: true
        )
      end
    end
  end
end
