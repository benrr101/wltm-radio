class Api::RequestController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /request/file/:term
  #   Required header: Auth
  def file
    id_translator = lambda {|path| [Track.create_from_file(path).id]}
    request_generic(FileSystem.method(:search_for_file), id_translator)
  end

  # POST /request/folder/:term
  #   Required header: Auth
  def folder
    id_translator = lambda {|path| FileSystem.get_all_folder_files(path).map {|f| Track.create_from_file(f).id}}
    request_generic(FileSystem.method(:search_for_folder), id_translator)
  end

  private
  def request_generic(match_finder, track_id_translator)
    # Check for the auth headers
    # Require that a username token be provided
    return unless HmacKey.validate(request.headers, request.raw_post, &method(:render_error))
    return unless param_check(params, :on_behalf_of, &method(:render_error))

    # Get matches using the method provided
    matches = match_finder.call(params[:term])

    # Ensure at least one match
    if matches.length == 0
      render :json => {:error => 'No matches found'}, :status => :not_found
      return
    end

    # Ensure only one match
    if matches.length > 1
      # Attempt to disambiguate the requests
      disambiguated_matches = FileSystem.disambiguate_items(matches)
      render :json => {:error => 'Search matched multiple items', :did_you_mean => disambiguated_matches},
             :status => 300   # Ambiguous Target
      return
    end

    # Translate the match item to track IDs and add to the buffer
    track_ids = track_id_translator.call(matches[0])
    response = BufferRecord.add_request(track_ids, params[:on_behalf_of])

    # Skip to the next track in the buffer
    MpdController.skip if HistoryRecord.last.bot_queued?

    # Add the tracks to the buffer and return the status
    render :json => response,
           :status => :ok
  end
end