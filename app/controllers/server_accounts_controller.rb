class ServerAccountsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_action :set_server_account, only: [:show, :edit, :update, :destroy]

  # GET /server_accounts
  # GET /server_accounts.json
  def index
    flash[:notice] = nil
    
    if params[:show_inactive] == 'true'
      @server_accounts = ServerAccount.all
    else
      @server_accounts = ServerAccount.where('Active = 1')
    end

    @server_accounts = @server_accounts.search(params[:search]).order(sort_column + " " + sort_direction).paginate(:per_page => 6, :page => params[:page])

    for server_account in @server_accounts
      server_account.SystemServer = get_value(Security.rc4_decrypt(server_account.Connection), 'Data Source=', ';')
      server_account.SystemDatabase = get_value(Security.rc4_decrypt(server_account.Connection), 'Initial Catalog=', ';')
    end
  end

  # GET /server_accounts/1
  # GET /server_accounts/1.json
  def show
    # test_connection
  end

  # GET /server_accounts/new
  def new
    @server_account = ServerAccount.new
    @save_button_caption = 'Save Account'
  end

  # GET /server_accounts/1/edit
  def edit
    @save_button_caption = 'Update Account'
    if !@server_account.nil?
      connection_string = connection_string_to_hash(@server_account.Connection)
      @server_account.SystemServer = connection_string['DataSource']
      @server_account.SystemDatabase = connection_string['InitialCatalog']
      @server_account_UseWindowsNT = connection_string['PersistSecurityInfo'] == 'True' ? false : true
      @server_account.UseWindowsNT = @server_account_UseWindowsNT
      @server_account.Username = connection_string['UserID']
      @server_account.Password = connection_string['Password']
    end
  end

  def string_after(str, search)
    start = str.index(search)
    if start.to_i > 0
      return str[start.to_i + search.length..str.length]
    end
    return ''
  end

  def get_value(str, strBefore, strAfter)
    tempstr = ''
    tempstr = str + strAfter
    tempstr = string_after(tempstr, strBefore)
    tempstr = tempstr.gsub(strAfter + string_after(tempstr, strAfter), '');
    return tempstr
  end

  def connection_string_to_hash(con_str)
    conn = Security.rc4_decrypt(con_str).gsub(' ', '')
    s = conn.split(';')
    arr = []
    s.each do |s1|
      s2 = s1.split('=')
      s2.each do |s3|
        arr << s3
      end
    end
    h = Hash[*arr]
    # return h
  end

  def test_connection
    begin
      @is_test_connection_failed = false
      h = {}
      @notice = ''
      if !params[:id].blank? && params[:is_editing] == 'false'
        db = ServerAccount.where('Id = ?', params[:id])

        if db[0].Connection.blank?
          account_code = params[:account_code]
          raise 'No specified database connection.'
        end

        connection_string = connection_string_to_hash(db[0].Connection)

        data_source = connection_string['DataSource'].gsub(',', ':')
        database = connection_string['InitialCatalog']
        use_windows_nt = connection_string['PersistSecurityInfo'] == 'True' ? false : true
        username = connection_string['UserID']
        password = connection_string['Password']
        account_code = db[0].AccountCode
      else
        data_source = params[:data_source].blank? ? '' : params[:data_source].gsub(',', ':')
        database = params[:database]
        use_windows_nt = params[:use_windows_nt] == 'true' ? true : false
        username = params[:username]
        account_code = params[:account_code]
        password = params[:password]

        if password == 'server_account_Password'
          db = ServerAccount.where('Id = ?', params[:id])
          password = db.length > 0 ? get_value(Security.rc4_decrypt(db[0].Connection), 'Password=', ';') : ''
        end
      end

      if data_source.index("\\").to_i > 0
        @notice = "Invalid system server format #{data_source} for #{account_code} client code. Valid format (IP,Port) E.g. localhost,1433 or 192.168.1.2,1433."
        @is_test_connection_failed = true
        return
      end

      if data_source.blank? || data_source == '' || data_source == 'undefined'
        return #No Server Account Id
      end

      h.merge!(:adapter => 'sqlserver')
      h.merge!(:encoding => 'utf8')
      h.merge!(:mode => 'dblib')
      h.merge!(:dataserver => data_source)
      h.merge!(:database => database)
      h.merge!(:timeout => 120) # wait for a response from mssql for 2 minutes
      h.merge!(:login_timeout => 10)
      
      if !use_windows_nt
        h.merge!(:username => username)
        h.merge!(:password => password)
      end

      client = TinyTds::Client.new(h) # for test connection only
      client.close
      # ActiveRecord::Base.establish_connection(h) #if changing connection
      @notice = "Test connection succeeded."
    rescue => e
      @notice = "Test connection failed because of an error in initializing provider. #{e.to_s.gsub("'", '')}"
      @is_test_connection_failed = true
    end

    respond_to do |format|
      format.js
    end
  end

  # POST /server_accounts
  # POST /server_accounts.json
  def create
    @save_button_caption = 'Saving Account'
    @server_account = ServerAccount.new(server_account_params)
    @server_account.SystemId = 1
    @server_account.UseSystemConnectionForWeb = true
    @server_account.Connection = '' if @server_account.Connection.blank?
    
    respond_to do |format|
      if @server_account.save
        # Add admin access for new server account by default 
        security_user_server_account = SecurityUserServerAccount.new(:SecurityUserId => 1, :ServerAccountId => @server_account.id)
        security_user_server_account.save

        format.html { redirect_to @server_account, notice: 'Server account was successfully created.' }
        format.json { render :show, status: :created, location: @server_account }
      else
        format.html { render :new }
        format.json { render json: @server_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /server_accounts/1
  # PATCH/PUT /server_accounts/1.json
  def update
    respond_to do |format|
      if @server_account.update(server_account_params)
        format.html { redirect_to @server_account, notice: 'Server account was successfully updated.' }
        format.json { render :show, status: :ok, location: @server_account }
      else
        format.html { render :edit }
        format.json { render json: @server_account.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_connection
    data_source = params[:data_source].blank? ? '' : "Data Source=#{params[:data_source].gsub(':', ',')}"
    database = params[:database].blank? ? '' : "Initial Catalog=#{params[:database]}"
    use_windows_nt = "Persist Security Info=#{params[:use_windows_nt] == 'true' ? 'False' : 'True'}"
    username = params[:username].blank? ? '' : "User ID=#{params[:username]}"
    password = params[:password].blank? ? '' : "Password=#{params[:password]}"

    if password == 'server_account_Password'
      db = ServerAccount.where('Id = ?', params[:id])
      password = db.length > 0 ? get_value(Security.rc4_decrypt(db[0].Connection), 'Password=', ';') : ''
    end

    connection = "Provider=SQLOLEDB.1;#{password};#{use_windows_nt};#{username};#{database};#{data_source}"
    @server_account_UseWindowsNT = params[:use_windows_nt] == 'true' ? true : false
    @connection = Security.rc4_encrypt(connection)

    respond_to do |format|
      # format.html {redirect_to "/#{params[:id]}"}
      format.js
    end
  end

  def enable_ess
    @id = params[:id].to_s
    is_ess_enabled = params[:is_ess_enabled] == 'Yes' ? true : false
    @enable_ess = is_ess_enabled ? 'false' : 'true'
    @client_code = params[:client_code]
    @link_caption = @enable_ess == 'true' ? 'Disable ESS' : 'Enable ESS'
    @notice = ''
    
    respond_to do |format|
      if !params[:id].blank? && ServerAccount.update(@id, {IsEnableESS: @enable_ess})
        @notice = "ESS for #{@client_code} is successfully #{@enable_ess == 'true' ? 'enabled' : 'disabled'}."
      end
      format.js
    end
  end

  # DELETE /server_accounts/1
  # DELETE /server_accounts/1.json
  def destroy
    @server_account.destroy
    respond_to do |format|
      format.html { redirect_to server_accounts_url, notice: 'Server account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_server_account
      flash[:notice] = nil
      @server_account = ServerAccount.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def server_account_params
      params.require(:server_account).permit(:AccountCode, :AccountName, :Connection, :Active, :IsEnableESS)
    end

    def sort_column
      ServerAccount.column_names.include?(params[:sort]) ? params[:sort] : "AccountCode"
    end
    
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
