class IndexController < ApplicationController
  def index
    @icecast_base = Rails.configuration.icecast['icecast_base']
    @random_string = SecureRandom.hex
  end

  def history
  end
end
