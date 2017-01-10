require 'rufus-scheduler'

############################################################################
# Skip task
# - Checks to see if the current
Rails.application.config.after_initialize do
  # Only define the task if we're in a server environment
  unless (defined?(Rails::Server) || defined?(ENV['server_name'])) && Rails.configuration.mpd['enable']
    Rails.logger.warn('Skip task will not be enabled since we are not in a server environment')
    next
  end

  # Create the rufus scheduler singleton
  s = Rufus::Scheduler.singleton

  # Setup the task to run every 5s
  s.every '5s', overlap: false do
    # If the currently playing track has over 50% vote to skip, skip it
    if Skip.current_skip_percentage >= Skip.skip_percentage_threshold
      MpdController.skip
    end
  end
end