require 'ruby-mpd'

  class Mpd

    class Status

      def initialize(is_running, queue_size, current_track)
        @is_running = is_running
        @queue_size = queue_size
        @current_track = current_track
      end

      # @return [bool]  Whether or not MPD is currently running
      def is_running
        @is_running
      end

      # @return [int] Number of tracks currently in the MPD queue
      def queue_size
        @queue_size
      end

      # @return [NowPlaying] Information about the currently playing track
      def current_track
        @current_track
      end
    end

    class NowPlaying

      # @param [string] artist  Name of the artist
      # @param [string] album Name of the album
      # @param [string] title Title of the track
      # @param [Time] time  Time statistics about the track
      # @param [string] who User that uploaded the track
      def initialize(artist, album, title, time, who)
        @artist = artist
        @album = album
        @title = title
        @time_stats = time
        @who = who
      end

      def artist
        @artist
      end

      def album
        @album
      end

      def title
        @title
      end

      def time_stats
        @time_stats
      end

      def who
        @who
      end
    end

    class Time

      def initialize(seconds_elapsed, seconds_remaining, seconds_total)
        @seconds_elapsed = seconds_elapsed
        @seconds_remaining = seconds_remaining
        @seconds_total = seconds_total
      end

      def seconds_elapsed
        @seconds_elapsed
      end

      def seconds_remaining
        @seconds_remaining
      end

      def seconds_total
        @seconds_total
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

        track = @mpd_connection.current_song
        who = track.file.sub(Rails.configuration.files['base_path'], '').sub(File::SEPARATOR, '').split(File::SEPARATOR)[0]
        time = Mpd.get_time(@mpd_connection)

        now_playing = NowPlaying.new(track.artist, track.album, track.title, time, who)
      rescue
        is_running = false
        queue_length = nil
        now_playing = nil
      ensure
        @mpd_connection.disconnect
      end

      Status.new(is_running, queue_length, now_playing)
    end

    # Presses the "next" button on MPD
    def next
      # fire up the connection
      @mpd_connection.connect
      begin
        # Next!
        @mpd_connection.next
      ensure
        # Make sure we always disconnect
        @mpd_connection.disconnect
      end
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
        return Mpd.get_time(@mpd_connection).seconds_remaining
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

    # PRIVATE HELPERS ########################################################

    # Fetches the time stats for the currently playing track
    # @param [MPD]  The MPD connection to use to get the time for current track
    # @return [Time]  Object with details of the time
    private
    def self.get_time(mpd_connection)
      begin
        seconds_elapsed = mpd_connection.status[:time][0]
        seconds_total = mpd_connection.status[:time][1]
        seconds_remaining = seconds_total - seconds_elapsed
        return Time.new(seconds_elapsed, seconds_remaining, seconds_total)
      rescue
        return nil
      end
    end
  end