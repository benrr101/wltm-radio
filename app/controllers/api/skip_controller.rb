class Api::SkipController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /skip
  #   Required header: Auth
  def skip
    # Check for the auth headers
    if request.headers['AUTHORIZATION'].nil?
      render :json => {:error => 'AUTHORIZATION header is required'},
             :status => :unauthorized
      return
    end

    # Make sure that the auth tokens are properly provided
    auth_tokens = request.headers['AUTHORIZATION'].split(':')
    unless auth_tokens.size == 2
      render :json => {:error => 'AUTHORIZATION header is malformed. Expected format like public:hash'},
             :status => :unauthorized
      return
    end

    # Calculate the expected HMAC and validate it
    unless HmacKey.validate_hash(auth_tokens[0], request.raw_post, auth_tokens[1])
      render :json => {:error => 'Invalid authorization. Either hash or public key is invalid'},
             :status => :unauthorized
      return
    end

    # Require that a username token be provided
    on_behalf_of = params[:on_behalf_of]
    if on_behalf_of.nil?
      render :json => {:error => 'on_behalf_of token not provided or content-type header not set properly'},
             :status => :bad_request
      return
    end

    # Add the skipper to the list of skippers
    current_history_id = HistoryRecord.last.id
    Skip.create(history_record_id: current_history_id, on_behalf_of: on_behalf_of)

    # Get the current number of skips and the current number of listeners
    current_listeners = IcecastStatus.get_status.current_listeners
    current_skips = Skip.where(:history_record_id => current_history_id).count

    render :json => {
        :success => true,
        :current_skips => current_skips,
        :current_listeners => current_listeners
    }, :status => :accepted
  end
end