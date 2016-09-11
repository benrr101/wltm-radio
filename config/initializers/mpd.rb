############################################################################
# Initializer for MPD
# - Ensures that consume mode is enabled on the MPD instance

Rails.application.config.after_initialize do
  mpd_model = Mpd.new

  # Ensure consume mode is turned of
  mpd_model.ensure_consume
end