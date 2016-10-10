module Api
  class StatsController < ApplicationController

    # GET /stats/share
    def share
      share_stat = FileSystem.get_status
      render :json => share_stat
    end

    # GET /stats/db
    def db
      #TODO: Add method for figuring out if the db is running
    end

    # GET /stats/mpd
    def mpd
      mpd_stat = Mpd.new.get_status
      render :json => mpd_stat
    end

    # GET /stats/icecast
    def icecast
      icecast_stat = IcecastStatus.get_status
      render :json => icecast_stat
    end
  end
end
