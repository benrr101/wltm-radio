require 'rufus-scheduler'

############################################################################
# Shuffle Enqueue Task
# - This task will enqueue up to the defined number of tracks to the buffer
#   from the included folders. Files are picked at random, without a shuffle
#   playlist being created.

Rails.application.config.after_initialize do
  # Create the rufus scheduler singleton
  s = Rufus::Scheduler.singleton


  # Setup the task to run every 10s
  s.every '10s' do
    # If there are less than 10 files in the buffer, add a new one to to the buffer
    if true # TODO: Hook this up with MySQL
      Rails.logger.info('Hello from the shuffle scheduler')
      shuffle_files = FileSystem.get_all_shuffle_files()
      shuffle_files = shuffle_files.shuffle()
      Rails.logger.info(shuffle_files[0])
    end
  end
end
