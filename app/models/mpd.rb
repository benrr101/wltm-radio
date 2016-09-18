require 'ruby-mpd'
require 'sys/proctable'

class Mpd

  class Status

    def initialize(is_running, accepting, queue_size)
      @accepting_connections = accepting
      @is_running = is_running
      @queue_size = queue_size
    end

    def accepting_connections
      @accepting_connections
    end

    def is_running
      @is_running
    end

    def queue_size
      @queue_size
    end

  end

  # Connection to MPD
  @mpd_connection = nil

  # Constructor, takes the info for the connection from the rails config
  def initialize
    @mpd_connection = MPD.new(Rails.configuration.mpd['socket'])
  end

  # INSTANCE METHODS #######################################################

  def get_status
    # Determine if MPD is running
    mpd_procs = Sys::ProcTable.ps.select{|process| process.name == 'mpd'}
    is_running = mpd_procs.count > 0

    # Determine how willing MPD is to accept connections
    begin
      @mpd_connection.connect
      accepting_connections = true
      queue_length = @mpd_connection.queue.count
    rescue
      accepting_connections = false
      queue_length = nil
    ensure
      @mpd_connection.disconnect
    end

    return Status.new(is_running, accepting_connections, queue_length)
  end

  # Adds a track to the play queue based on its absolute path
  # @param [string] abs_path  Absolute path to the track to add to the queue
  def queue_add(abs_path)
    # fire up the connection
    @mpd_connection.connect
    begin
      # Add a new track to the queue
      @mpd_connection.add(abs_path)

      # If we're not already playing, we need to start playback
      @mpd_connection.play unless @mpd_connection.playing?
    ensure
      # Make sure we always disconnect
      @mpd_connection.disconnect
    end
  end

  # @return [int]   The number of tracks currently in the play queue
  def queue_length
    # fire up the connection
    @mpd_connection.connect
    begin
      return @mpd_connection.queue.count
    ensure
      # Make sure we always disconnect
      @mpd_connection.disconnect
    end
  end

  # @return [int?]  The number of seconds remaining for the currently playing track
  #                 Nil is returned if the nothing is playing currently
  def remaining_time
    # fire up the connection
    @mpd_connection.connect
    begin
      # If we're not playing, return nil
      unless @mpd_connection.playing?
        return nil
      end

      # We are playing, so return the number of seconds that are left
      seconds_played = @mpd_connection.status[:time][0]
      seconds_total = @mpd_connection.status[:time][1]
      seconds_left = seconds_total - seconds_played
      return seconds_left
    ensure
      @mpd_connection.disconnect
    end
  end

  # Ensures that consume mode is turned on for MPD
  # @return [bool]  True if successfully set to true, false otherwise
  def ensure_consume
    # fire up the connection
    @mpd_connection.connect
    begin
      # force consume mode on
      return @mpd_connection.consume = true
    ensure
      @mpd_connection.disconnect
    end
  end
end