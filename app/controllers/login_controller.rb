class LoginController < ApplicationController
  skip_before_action :secure

  def index
    redirect_to '/server_accounts' if !session[:user_id].nil?
  end

  def authenticate
    login_name = params[:user_name]
    password = params[:password]

    if login_name.index("\\").to_i > 0
      login_name = !login_name.blank? ? login_name.split("\\")[1] : ''
    end

    login_name = !login_name.blank? ? login_name.split('@')[0] : ''

    user = User.find_by_LoginName(login_name)
    if user.nil?
      flash[:message] = 'Access Denied'
      redirect_to action: :index
    else
      if User.is_valid_password?(login_name, password)
        session[:user_id] = user.id
        session[:user_name] = user.UserName
        redirect_to '/server_accounts'
      else
        flash[:message] = 'Access Denied'
        redirect_to action: :index
      end
    end
  end

  def test
  end

  private

  def sha256(str)
    return Digest::SHA256.hexdigest(str).upcase
  end
end
