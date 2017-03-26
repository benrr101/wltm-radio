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
    remaining_time = mpd.remaining_time || 0
    if mpd.queue_length < 2 && remaining_time <= 10
      MpdController.enqueue_next(remaining_time)
    else
      Rails.logger.debug("Current track has #{remaining_time}s left and #{mpd.queue_length} track in queue, no tracks will be added to queue")
    end
  end
end
