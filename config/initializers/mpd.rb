############################################################################
# Initializer for MPD
# - Ensures that consume mode is enabled on the MPD instance

Rails.application.config.after_initialize do
  begin
    # Ensure consume mode is turned on
    mpd_model = Mpd.new
    mpd_model.ensure_consume
  rescue Exception => e
    Rails.logger.error("Exception during initialization of MPD #{e.message}")
    Rails.logger.error('MPD functionality will not work')
  end
end