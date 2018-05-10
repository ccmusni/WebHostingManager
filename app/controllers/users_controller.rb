class UsersController < ApplicationController
  skip_before_action :secure
  def index
    redirect_to action: :new
  end

  def new
    @user = User.new
  end

  def create
    flash[:error_messages] = nil
    user_name = params[:UserName]
    login_name = params[:LoginName]

    if login_name.index("\\").to_i > 0
      login_name = !login_name.blank? ? login_name.split("\\")[1] : ''
    end
    login_name = !login_name.blank? ? login_name.split('@')[0] : ''
    password = params[:password]

    @user = User.new
    @user.UserName = user_name
    @user.LoginName = login_name
    @user.PasswordNeverExpires = true
    @user.PasswordHash = password.blank? ? nil : -1
    
    if @user.valid?
      if User.is_valid_password?(login_name, password)
        User.connection.execute('ALTER TABLE tblSecurityUsers DISABLE TRIGGER ALL') #Disable Triggers, unable to save when there is enabled triggers due to rails saving syntax OUTPUT
        @user.save
        User.connection.execute('ALTER TABLE tblSecurityUsers ENABLE TRIGGER ALL')
        
        flash[:info] = 'You have signed up successfully. Try login now!'
        redirect_to controller: :login
      else
        if password.blank?
          @user.errors[:base] << 'Password is required.'
        else
          @user.errors[:base] << 'Wrong username or password.'
        end
        render action: :new
      end
    else
      render action: :new
    end
  end

end
