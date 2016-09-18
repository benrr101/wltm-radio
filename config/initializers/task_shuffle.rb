require 'rufus-scheduler'

############################################################################
# Shuffle Enqueue Task
# - This task will enqueue up to the defined number of tracks to the buffer
#   from the included folders. Files are picked at random, without a shuffle
#   playlist being created.

Rails.application.config.after_initialize do
  # Only define the task if we're in a server environment
  if (not defined?(Rails::Server)) || File.split($0).last == 'rake'
    Rails.logger.info('Shuffler task will not be enabled since we are not in a server environment')
    next
  end

  # Create the rufus scheduler singleton
  s = Rufus::Scheduler.singleton

  # Setup the task to run every 10s
  s.every '10s', overlap: false do
    # If there are less than 10 files in the buffer, add a new one to to the buffer
    buffer_count = BufferRecord.count
    if buffer_count < Rails.configuration.queues['buffer_max_tracks']
      # Get all the eligible files, shuffle, and pick one
      shuffle_files = FileSystem.get_all_shuffle_files
      shuffle_files = shuffle_files.shuffle
      if shuffle_files.count == 0
        Rails.logger.error('Failed to find tracks to add to buffer!')
      end

      shuffle_pick = shuffle_files[0]

      # Add it to the buffer
      # TODO: Top off buffer instead of adding one
      Rails.logger.info("Adding 1 track to buffer: '#{shuffle_pick}'")
      BufferRecord.create(
          absolute_path: shuffle_pick,
          on_behalf_of: 'shuffle_bot',
          bot_queued: true
      )
    else
      Rails.logger.info("Buffer contains #{buffer_count} tracks, no more will be added")
    end
  end
end
