class Api::SkipController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /skip
  #   Required header: Auth
  def skip
    # Check for the auth headers
    validation = HmacKey.validate(request.headers, request.raw_post) do |error, code|
      render :json => {:error => error}, :status => code
    end
    return unless validation

    # Require that a username token be provided
    on_behalf_of = params[:on_behalf_of]
    if on_behalf_of.nil?
      render :json => {:error => 'on_behalf_of token not provided or content-type header not set properly'},
             :status => :bad_request
      return
    end

    # Require that the user hasn't already voted to skip
    current_history_id = HistoryRecord.last.id
    if Skip.where(:history_record_id => current_history_id, :on_behalf_of => on_behalf_of).exists?
      render :json => {:error => 'on_behalf_of user cannot vote to skip current track more than once'},
             :status => :bad_request
      return
    end

    # Add the skipper to the list of skippers

    Skip.create(history_record_id: current_history_id, on_behalf_of: on_behalf_of)

    render :json => {
        :success => true,
        :current_skips => Skip.current_skip_count,
        :current_listeners => IcecastStatus.get_status.current_listeners,
        :current_skip_percentage => Skip.current_skip_percentage,
        :skip_percentage_threshold => Skip.skip_percentage_threshold
    }, :status => :accepted
  end
end