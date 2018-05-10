class LogoutController < ApplicationController
  skip_before_action :secure

  def index
    reset_session
    redirect_to controller: :login
  end
end