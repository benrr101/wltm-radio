class Api::RequestController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /request/file/:term
  #   Required header: Auth
  def file
    # Check for the auth headers
    validation = HmacKey.validate(request.headers, request.raw_post) do |error, code|
      render :json => {:error => error}, :status => code
    end
    return unless validation

    # Require that a username token be provided
    on_behalf_of = params[:on_behalf_of]
    if on_behalf_of.nil?
      render :json => {:error => 'on_behalf_of token not provided'},
             :status => :bad_request
      return
    end

    render :json => FileSystem.search_for_file(params[:term])
  end

  # POST /request/folder/:term
  #   Required header: Auth
  def folder
    # Check for the auth headers
    validation = HmacKey.validate(request.headers, request.raw_post) do |error, code|
      render :json => {:error => error} , :status => code
    end
    return unless validation

    # Require that a username token be provided
    on_behalf_of = params[:on_behalf_of]
    if on_behalf_of.nil?
      render :json => {:error => 'on_behalf_of token not provided'},
             :status => :bad_request
      return
    end

    render :json => FileSystem.search_for_folder(params[:term])
  end
end