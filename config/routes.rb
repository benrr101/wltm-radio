Rails.application.routes.draw do
  # GET /index, the default route
  root :to => 'index#index'
  get 'index', to: 'index#index'
  get 'history', to: 'index#history'

  namespace :api, constraints: {format: 'json'}, defaults: {format: false} do
    # STATS CONTROLLER #####################################################

    # GET /stats/share
    get '/stats/share', to: 'stats#share'

    # GET /stats/db
    get '/stats/db', to: 'stats#db'

    # GET /stats/mpd
    get '/stats/mpd', to: 'stats#mpd'

    # GET /stats/icecast
    get '/stats/icecast', to: 'stats#icecast'

    # HISTORY CONTROLLER ###################################################

    # GET /history/current
    get 'history/current', to: 'history#current'

    # GET /history/date?start=unix&end=unix
    get 'history/date', to: 'history#date'

    # REQUEST CONTROLLER ###################################################

    # POST /request/folder
    post 'request/folder/:term', to: 'request#folder', constraints: {:term => /[^\/]+/}

    # POST /request/file
    post 'request/file/:term', to: 'request#file', constraints: {:term => /[^\/]+/}

    # SKIP CONTROLLER ######################################################

    # POST /skip
    post 'skip', to: 'skip#skip'

    # ART CONTROLLER #######################################################

    # GET /art/:hash, to: 'art#hash'
    get 'art/:hash', to: 'art#hash'
  end
end
