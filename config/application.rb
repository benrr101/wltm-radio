require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

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
  end
end
