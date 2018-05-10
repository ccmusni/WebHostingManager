class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :secure
  # include ApplicationHelper

  def secure
    if session[:user_id].nil?
      redirect_to controller: :logout
    end
  end
end
