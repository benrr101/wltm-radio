require 'ruby-mpd'

class Mpd

  class Status

    def initialize(is_running, queue_size, current_track, who)
      @is_running = is_running
      @queue_size = queue_size
      @current_track = current_track
      @who = who
    end

    def is_running
      @is_running
    end

    def queue_size
      @queue_size
    end

    def current_track
      @current_track
    end

    def who
      @who
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
    # Determine how willing MPD is to accept connections
    begin
      @mpd_connection.connect
      is_running = true
      queue_length = @mpd_connection.queue.count

      current_track_obj = @mpd_connection.current_song
      current_track = "#{current_track_obj.artist} - #{current_track_obj.title}"
      who = @mpd_connection.current_song.file.sub(Rails.configuration.files['base_path'], '').sub(File::SEPARATOR, '').split(File::SEPARATOR)[0]

    rescue
      is_running = false
      queue_length = nil
      current_track = nil
      who = nil
    ensure
      @mpd_connection.disconnect
    end

    Status.new(is_running, queue_length, current_track, who)
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