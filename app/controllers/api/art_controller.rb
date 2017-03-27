class Api::ArtController < ApplicationController
  # GET /art/:hash
  def hash
    # Get the art that was requested
    art = Art.find_by_hash_code(params[:hash])
    if art.nil?
      render :json => {:errors => "Hash #{params[:hash]} could not be found"},
             :status => :not_found
      return
    end

    # Send headers and content for the art
    response.headers['Content-Type'] = art.mimetype
    response.headers['Content-Size'] = art.bytes.length
    response.stream.write art.bytes
    response.stream.close
  end
end