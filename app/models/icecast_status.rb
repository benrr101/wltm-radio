require 'icecast'

class IcecastStatus

  class Status
    def initialize(is_running, current_listeners, max_listeners)
      @is_running = is_running
      @current_listeners = current_listeners
      @max_listeners = max_listeners

      @connection_ratio = @current_listeners.to_i / @max_listeners.to_f
    end

    def is_running
      @is_running
    end

    def current_listeners
      @current_listeners
    end

    def max_listeners
      @max_listeners
    end

    def connection_ratio
      @connection_ratio
    end
  end

  def self.get_status
    server_attribs = {
        :admin_password => Rails.configuration.icecast['admin_password'],
        :host => Rails.configuration.icecast['hostname'],
        :port => Rails.configuration.icecast['port']
    }

    begin
      Icecast::Server.cache = Icecast::Server::NullCache.new      # This is to work around a bug in the Icecast gem
      icecast_status = Icecast::Server.new(server_attribs).status.parsed_status['icestats']
      is_running = true

      total_listeners = icecast_status['listeners']
      sources = icecast_status['source']

      total_max_listeners = 0
      sources.each do |source|
        total_max_listeners += source['max_listeners'] == 'unlimited' ? Float::INFINITY : source['max_listeners']
      end
    rescue => e
      Rails.logger.warn("Failed to connect to icecast: #{e}")
      is_running = false
      total_listeners = nil
      total_max_listeners = nil
    end

    return Status.new(is_running, total_listeners, total_max_listeners)
  end

end