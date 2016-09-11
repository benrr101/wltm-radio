############################################################################
# Initializer for MPD
# - Ensures that consume mode is enabled on the MPD instance

Rails.application.config.after_initialize do
  # Ensure consume mode is turned of
  Mpd.ensure_consume
end