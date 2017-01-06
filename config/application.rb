require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# For Rufus to work correctly on Windows, we need to set a timezone in the environment. Although
# this isn't an ideal situation, I'm going to force it to UTC
ENV['TZ'] = 'UTC'

module WLTMRadioApi2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Load up the file config
    Rails.configuration.files = config_for(:files)

    # Load up the queue config
    Rails.configuration.queues = config_for(:queues)

    # Load up the MPD config
    Rails.configuration.mpd = config_for(:mpd)

    # Load up the config for Icecast
    Rails.configuration.icecast = config_for(:icecast)
  end
end
