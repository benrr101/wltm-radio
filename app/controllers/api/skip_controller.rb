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
      render :json => {:error => 'on_behalf_of token not provided'},
             :status => :bad_request
      return
    end

    render :json => {:success => true},
           :status => :accepted
  end
end