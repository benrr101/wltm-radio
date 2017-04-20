class Api::RequestController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /request/file/:term
  #   Required header: Auth
  def file
    track_resolver = lambda {|path| [path]}
    request_generic(FileSystem.method(:search_for_file), track_resolver)
  end

  # POST /request/folder/:term
  #   Required header: Auth
  def folder
    track_resolver = lambda {|path| FileSystem.get_all_folder_files(path)}
    request_generic(FileSystem.method(:search_for_folder), track_resolver)
  end

  private
  def request_generic(match_finder, track_resolver)
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
    tracks = track_resolver.call(matches[0]).map {|path| Track.create_from_file(path)}
    if tracks.size == 0
      short_path = File.basename(matches[0])
      render :json => {:error => "Match #{short_path} did not contain any audio files"},
             :status => 204   # No content
      return
    end

    response = BufferRecord.add_request(tracks, params[:on_behalf_of])

    # Figure out how many seconds are remaining
    remaining_seconds = response[:seconds_remaining] + (Mpd.new.remaining_time || 0)

    # Add the tracks to the buffer and return the status
    render :json => {
        :seconds_remaining => remaining_seconds,
        :tracks => tracks.map {|t| t.serializable_hash(Track.serializable_hash_options)},
        :tracks_enqueued => response[:tracks_enqueued]
    }, :status => :ok
  end
end