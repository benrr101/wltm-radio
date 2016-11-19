Rails.application.routes.draw do
  # GET /index, the default route
  root :to => 'index#index'
  get 'index', to: 'index#index'
  get 'history', to: 'index#history'

  namespace :api, constraints: {format: 'json'}, defaults: {format: 'json'} do
    # GET /stats/share
    get '/stats/share', to: 'stats#share'

    # GET /stats/db
    get '/stats/db', to: 'stats#db'

    # GET /stats/mpd
    get '/stats/mpd', to: 'stats#mpd'

    # GET /stats/icecast
    get '/stats/icecast', to: 'stats#icecast'

    # GET /history/current
    get 'history/current', to: 'history#current'

    # GET /history/date?start=unix&end=unix
    get 'history/date', to: 'history#date'

    # GET /history/page?pagesize=?[&page=?]
    get 'history/page', to: 'history#page'
  end
end
