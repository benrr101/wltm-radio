class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def render_error(error, response_code)
    render :json => {:error => error} , :status => response_code
  end

  def param_check(params, param_name)
    if params[param_name].nil?
      yield("Parameter '#{param_name}' not provided", :bad_request)
      return false
    end

    true
  end
end
