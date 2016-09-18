############################################################################
# Initializer for MPD
# - Ensures that consume mode is enabled on the MPD instance

Rails.application.config.after_initialize do
  # Only define the task if we're in a server environment
  if (not defined?(Rails::Server)) || File.split($0).last == 'rake' || (not Rails.configuration.mpd['enable'])
    Rails.logger.info('MPD will not be initialized, Rails is not a server environment, or MPD support is disabled')
    next
  end

  # Ensure consume mode is turned on
  mpd_model = Mpd.new
  mpd_model.ensure_consume
end