Rails.application.routes.draw do
  namespace :api, constraints: {format: 'json'}, defaults: {format: 'json'} do
    # GET /stats/share
    get '/stats/share', to: 'stats#share'

    # GET /stats/db
    get '/stats/db', to: 'stats#db'

    # GET /stats/mpd
    get '/stats/mpd', to: 'stats#mpd'

    # GET /stats/icecast
    get '/stats/icecast', to: 'stats#icecast'
  end
end
