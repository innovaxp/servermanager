class RemoteServersController < ApplicationController
  # GET /remote_servers
  # GET /remote_servers.json

  before_filter :set_section

  def set_section
    @section = 'remoteservers'
  end

  #muestra el formulario para crear el cron
  def new_cron
    @remote_server = RemoteServer.find_by_id(params[:remote_server_id])
    
    respond_to do |format|
      format.html # (en el caso de que el fichero que renderizas tenga nombre distinto al nombre de la action){render => <nombre fichero>}
    end
  end


  def create_cron

    selected_fields = params.select {|key, val| key.to_s.match(/^(minute|hour|day|weekday|month|command)/i)}

    #recojo el campo hidden
    @remote_server = RemoteServer.find_by_id(params[:remote_server_id])

    #cron de un account
    param = ''
    selected_fields.each do |field|
      if ! param.nil?
        param = param + field[1].to_s + ' '
      end
    end

    result = Hash.new

    status = ''
     options = {'minute' => params[:minute],
                'hour' => params[:hour],
                'day' => params[:day],
                'weekday' => params[:weekday],
                'month' => params[:month],
                'command' => params[:command],
                'active' => params[:active]
     }
    Alert.send_notification('cron', options , @remote_server)
    if params[:active] && params[:active] == 1 || params[:active] == '1'
      status = 'active'
    else
      status = 'inactive'
    end

    result = @remote_server.create_cron(param, status)

    respond_to do |format|
      if result && result['status'] == 'success'
        flash[:success] = _('Cron created successfully')
        format.html {redirect_to :action => 'show_crons', :account_remote_servers_id => @remote_server.id}
      else
        flash[:error] = result['message']
        format.html {render :action => 'new_cron'}
      end
    end

  end

  def show_crons
    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])

    respond_to do |format|
      format.html # (en el caso de que el fichero que renderizas tenga nombre distinto al nombre de la action){render => <nombre fichero>}
    end
  end

  def toggle_cron_activation
    #raise 'dentro de cron acivation'
    @remote_server = RemoteServer.find_by_id(params[:account_remote_servers_id])
    #@account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])
    #raise @remote_server.to_yaml
    #raise params[:status].to_s
    #raise params[:line_n].to_s
    
    if params[:line_n]
      line_n = params[:line_n]
    end
    
    if params[:status] 
      status = params[:status].to_s
    end
    
    result = @remote_server.toggle_cron_activation(line_n, status)
    #result = @account_remote_server.toggle_cron_activation(line_n, status)
    respond_to do |format|
      if result && result['status'] == 'success'
        flash[:success] = _('Status modified successfully')
        format.html {redirect_to request.referer}
      else
        flash[:error] = result['message']
        format.html {render :action => 'show_crons'}
      end
    end
    
  end

  def delete_cron
    #raise "dentro de delete cron"
    @remote_server = RemoteServer.find_by_id(params[:remote_server_id])
    #raise @remote_server.to_yaml
    raise params[:line_n].to_s+' queda delete del cron'
    line_n = params[:line_n]
    
    result = @remote_server.delete_cron(line_n)

    respond_to do |format|
      if result && result['status'] == 'success'
        flash[:success] = _('Cron deleted successfully')
        format.html {redirect_to request.referer}
      else
        flash[:error] = result['message']
        format.html {render :action => 'show_crons'}
      end
    end
  end

  #muestra el formulario para crear el account
  def new_account
    @remote_server = AccountRemoteServer.new
    @remote_server.root_remote_server_id = params[:root_remote_server_id]

    respond_to do |format|
      format.html # (en el caso de que el fichero que renderizas tenga nombre distinto al nombre de la action){render => <nombre fichero>}
    end
  end

  def create_account


    meta_type_vals = params[:remote_server][:meta]
    params[:remote_server].delete(:meta)

    @remote_server = AccountRemoteServer.new(params[:remote_server])
    @remote_server.owner_id = session[:owner_id]
    @remote_server.meta = {'lang' => meta_type_vals }
    #raise params.to_yaml
    @remote_server.create_account_on_server(params[:remote_server][:user], params[:remote_server][:password], params[:remote_server][:host], @remote_server.meta['lang'].to_s)

    Alert.send_notification('account', @remote_server , @remote_server.root_remote_server)

    respond_to do |format|
      if @remote_server.save
        format.html { redirect_to remote_servers_path+'?open_account='+@remote_server.root_remote_server_id.to_s, notice: 'Account remote server was successfully created.' }
        #format.html { redirect_to remote_servers_url, notice: 'Account remote server was successfully created.' }
        format.json { render json: @remote_server, status: :created, location: @remote_server }
      else
        format.html { render action: "new_account" }
        format.json { render json: @remote_server.errors, status: :unprocessable_entity }
      end
    end
    
  end

  def edit_account
    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])
    @remote_server = RemoteServer.find_by_id(params[:id])
    @remote_server.password = ''
    
    respond_to do |format|
      format.html
    end
  end

  def update_account

    @remote_server = RemoteServer.find(params[:id])
    #raise @remote_server.to_yaml
    old_pass = @remote_server.password
    #raise @old_pass.to_s
    #raise params.to_yaml
    meta_type_vals = params[:remote_server][:meta]

    params[:remote_server][:meta] = {'lang' => meta_type_vals }
    #raise params.to_yaml
    #raise params[:remote_server][:password_change].to_s
    if params[:action] == 'edit_account' && params[:password_change]== 1 || params[:password_change]== '1' && params[:remote_server][:password] != '' && params[:remote_server][:password_confirmation] != ''
      #
      #raise params[:remote_server][:password].to_s
      @remote_server.update_server_password(old_pass, params[:remote_server][:password])
    end

    respond_to do |format|
      if @remote_server.update_attributes(params[:remote_server])
        format.html { redirect_to remote_servers_path+'?open_account='+@remote_server.root_remote_server_id.to_s, notice: 'Remote server was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "index" }
        format.json { render json: @remote_server.errors, status: :unprocessable_entity }
      end
    end
  end

  def new_email_account
    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])
    
    if @account_remote_server.host =~ /([a-z0-9]*?\.){2}/i
      #tiene subdominio (www.dominio.com)
      @clean_host = @account_remote_server.host.sub(/[a-z0-9]*?\./,'')
    else
      #no tiene subdominio (dominio.com)
      @clean_host = @account_remote_server.host
    end

    respond_to do |format|
      format.html # (en el caso de que el fichero que renderizas tenga nombre distinto al nombre de la action){render => <nombre fichero>}
    end
  end

  def create_email_account

    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])

    @clean_host = @account_remote_server.get_clean_domain
    @user_name = params[:user]
    result = Hash.new

    if params[:password] != params[:password_confirmation]
      
           
      result['status'] = 'error'
      result['message'] = _('Passwords must be equal')

    elsif !( params[:user] =~ /^[a-zA-Z0-9_\-\.]+?$/i )
      result['status'] = 'error'
      result['message'] = _('Account name has invalid characters (use only letters, numbers, _, - or .)')
    else
      
      acc_address = params[:user]+'@'+params[:clean_host]

      result = @account_remote_server.create_email_account(acc_address, params[:password])

    end

    options = {'account_name' => acc_address.to_s,
                'password' => params[:password]
              }
    Alert.send_notification('email_account', options , @remote_server)
    
    respond_to do |format|
      if result && result['status'] == 'success'
        flash[:success] = _('Account created successfully')
        format.html {redirect_to :action => 'show_emails_account', :account_remote_servers_id => @account_remote_server.id}
      else
        flash[:error] = result['message']
        format.html {render :action => 'new_email_account'}
      end
    end
  end

  def edit_email_account

    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])

    @clean_host = @account_remote_server.get_clean_domain
    @user_name = params[:user].sub('@'+@clean_host, '')
    
    respond_to do |format|
      format.html # (en el caso de que el fichero que renderizas tenga nombre distinto al nombre de la action){render => <nombre fichero>}
    end
  end

  def delete_email_account
    raise "dentro de delete_email_account"
    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])

    @clean_host = @account_remote_server.get_clean_domain
    @from = params[:email_from]
    @to = params[:email_to]

    result = @account_remote_server.delete_email_account(@from, @to)

    respond_to do |format|
      if result && result['status'] == 'success'
        flash[:success] = _('Email forward deleted successfully')
        format.html {redirect_to :action => 'show_emails_forwarders', :account_remote_servers_id => @account_remote_server.id}
      else
        flash[:error] = result['message']
        format.html {render :action => 'new_email_forward'}
      end
    end
  end

  def update_email_account


    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])

    @clean_host = @account_remote_server.get_clean_domain
    @user_name = params[:user]
    result = Hash.new

    if params[:password] && params[:password_confirmation] && params[:password] != params[:password_confirmation]
      #raise 'entra pass !='
      result['status'] = 'error'
      result['message'] = _('Passwords must be equal')

    elsif params[:password] && params[:password_confirmation] && params[:password] == params[:password_confirmation] && params[:password] != '' && params[:password_confirmation] != ''

      acc_address = params[:user]+'@'+params[:clean_host]

      result = @account_remote_server.update_email_account(acc_address, params[:password])
    else
      result['status'] = 'success'
      
    end

    respond_to do |format|
      if result && result['status'] == 'success'
        flash[:success] = _('Email account edited successfully')
        format.html{ redirect_to remote_servers_path }
      elsif result && result['status'] == 'error'
        flash[:error] = result['message']
        format.html {render :action => 'edit_email_account'}
      end
    end
  end

  def show_emails_account
    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])
    
    respond_to do |format|
      format.html # (en el caso de que el fichero que renderizas tenga nombre distinto al nombre de la action){render => <nombre fichero>}
    end
  end

  def new_email_forward
    
    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])

    if @account_remote_server.host =~ /([a-z0-9]*?\.){2}/i
      #tiene subdominio (www.dominio.com)
      @clean_host = @account_remote_server.host.sub(/[a-z0-9]*?\./,'')
    else
      #no tiene subdominio (dominio.com)
      @clean_host = @account_remote_server.host
    end
    
    respond_to do |format|
      format.html # (en el caso de que el fichero que renderizas tenga nombre distinto al nombre de la action){render => <nombre fichero>}
    end
  end

  def create_email_forward
    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])

    @clean_host = @account_remote_server.get_clean_domain
    if params[:select_email_from] == '--'
      @from = params[:email_from]+'@'+@account_remote_server.host.to_s
    else
      @from = params[:select_email_from]
    end
    @to = params[:email_to]
    #raise @from.to_s
    result = @account_remote_server.create_email_forward(@from, @to)

    options = {'email_from' => params[:email_from],
                'email_to' => params[:email_to]
              }
    Alert.send_notification('email_forward', options , @remote_server)
    
    respond_to do |format|
      if result && result['status'] == 'success'
        flash[:success] = _('Email forward created successfully')
        format.html { redirect_to :action => 'show_emails_forwarders', :account_remote_servers_id => @account_remote_server.id }
      else
        flash[:error] = result['message']
        format.html {render :action => 'new_email_forward'}
      end
    end
  end

  def delete_email_forward
    
    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])

    @clean_host = @account_remote_server.get_clean_domain
    @from = params[:from]
    @to = params[:to]

    result = @account_remote_server.delete_email_forward(@from, @to)
    
    respond_to do |format|
      if result && result['status'] == 'success'
        flash[:success] = _('Email forward deleted successfully')
        format.html {redirect_to :action => 'show_emails_forwarders', :account_remote_servers_id => @account_remote_server.id}
      else
        flash[:error] = result['message']
        format.html {render :action => 'new_email_forward'}
      end
    end
  end

  def show_emails_forwarders

    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])
    @clean_host = @account_remote_server.get_clean_domain
    
    respond_to do |format|
      format.html # (en el caso de que el fichero que renderizas tenga nombre distinto al nombre de la action){render => <nombre fichero>}
    end

  end

  def new_catch_all
    #raise "dentro de new_catch-all"
    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])
    #raise @account_remote_server.to_yaml
    respond_to do |format|
      format.html # (en el caso de que el fichero que renderizas tenga nombre distinto al nombre de la action){render => <nombre fichero>}
    end
  end

  def create_catch_all
    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])

    result = Hash.new
    result = @account_remote_server.create_catch_all(params[:email_to])

    options = {'email_to' => params[:email_to]}
    
    Alert.send_notification('catch_all', options , @remote_server)

    respond_to do |format|
      if result && result['status'] == 'success'
        flash[:success] = _('Account created successfully')
        format.html {redirect_to :action => 'new_catch_all', :account_remote_servers_id => @account_remote_server.id}
      else
        flash[:error] = result['message']
        format.html {render :action => 'new_catch_all'}
      end
    end

  end

  def delete_catch_all

    @account_remote_server = AccountRemoteServer.find_by_id(params[:account_remote_servers_id])

    @clean_host = @account_remote_server.get_clean_domain
    @to = params[:to]
    #raise @to.to_s

    result = @account_remote_server.delete_catch_all(@to)

    respond_to do |format|
      if result && result['status'] == 'success'
        flash[:success] = _('Email forward deleted successfully')
        format.html {redirect_to :action => 'new_catch_all', :account_remote_servers_id => @account_remote_server.id}
      else
        flash[:error] = result['message']
        format.html {render :action => 'new_catch_all'}
      end
    end
  end

  def get_all_accounts

  end

  def get_all_crons

  end
  
  def index
    #@remote_servers = RemoteServer.find_all_by_owner_id(session[:owner_id])
    #busco los que son del tipo remote_server, root_remote_server o null
    @remote_servers = RemoteServer.find(:all, :conditions => [ "type IS NULL or type = ? or type = ? AND owner_id = ?", "RemoteServer", "RootRemoteServer", session[:owner_id] ])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @remote_servers }
    end
  end

  # GET /remote_servers/1
  # GET /remote_servers/1.json
  def show
    @remote_server = RemoteServer.find_by_id_and_owner_id(params[:id], session[:owner_id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @remote_server }
    end
  end

  # GET /remote_servers/new
  # GET /remote_servers/new.json
  def new
    @remote_server = RemoteServer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @remote_server }
    end
  end

  # GET /remote_servers/1/edit
  def edit
    @remote_server = RemoteServer.find_by_id_and_owner_id(params[:id], session[:owner_id])
  end

  # POST /remote_servers
  # POST /remote_servers.json
  def create

    type = params[:remote_server][:type]

    params[:remote_server].delete(:type)

    @remote_server = eval(type).new(params[:remote_server])
    #@remote_server = RemoteServer.new(params[:remote_server])
    @remote_server.owner_id = session[:owner_id]
    respond_to do |format|
      if @remote_server.save
        format.html { redirect_to remote_servers_url, notice: 'Remote server was successfully created.' }
        format.json { render json: @remote_server, status: :created, location: @remote_server }
      else
        format.html { render action: "new" }
        format.json { render json: @remote_server.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /remote_servers/1
  # PUT /remote_servers/1.json
  def update

    type = params[:remote_server][:type]

    params[:remote_server].delete(:type)

    RemoteServer.update_all(['type = ?', type], ['id = ?', params[:id]])
    
    @remote_server = eval(type).find(params[:id])
    #@remote_server = RemoteServer.find(params[:id])

    respond_to do |format|
      if @remote_server.update_attributes(params[:remote_server])
        format.html { redirect_to remote_servers_url, notice: 'Remote server was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @remote_server.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /remote_servers/1
  # DELETE /remote_servers/1.json
  def destroy
    @remote_server = RemoteServer.find_by_id_and_owner_id(params[:id], session[:owner_id])
    @remote_server.destroy

    respond_to do |format|
      format.html { redirect_to remote_servers_url }
      format.json { head :no_content }
    end
  end

  def new_dns
    @remote_server = RemoteServer.find_by_id(params[:remote_server_id])

    @tipo_dns = 
      {'A' => 'A',
      'CNAME' => 'CNAME'}
 
    respond_to do |format|
      format.html # (en el caso de que el fichero que renderizas tenga nombre distinto al nombre de la action){render => <nombre fichero>}
    end
  end

  def edit_dns
    @remote_server = RemoteServer.find_by_id(params[:remote_server_id])

    @tipo_dns =
      {'A' => 'A',
      'CNAME' => 'CNAME'}

    respond_to do |format|
      format.html # (en el caso de que el fichero que renderizas tenga nombre distinto al nombre de la action){render => <nombre fichero>}
    end
  end

  def create_dns
    @remote_server = RemoteServer.find_by_id(params[:remote_server_id])

    @source = params[:source]
    @type = params[:type]
    @destination = params[:destination]

    result = @remote_server.create_dns(@source, @type, @destination)

    respond_to do |format|
      if result && result['status'] == 'success'
        flash[:success] = _('DNS created successfully')
        format.html {redirect_to :action => 'show_dns_managements', :remote_servers_id => @remote_server.id}
      else
        flash[:error] = result['message']
        format.html {render :action => 'new_dns'}
      end
    end
  end

  def update_dns
    @remote_server = RemoteServer.find_by_id(params[:remote_server_id])

    @source = params[:source]
    @type = params[:type]
    @destination = params[:destination]

    result = @remote_server.update_dns(@source, @type, @destination)

    respond_to do |format|
      if result && result['status'] == 'success'
        flash[:success] = _('DNS updated successfully')
        format.html {redirect_to :action => 'show_dns_managements', :remote_servers_id => @remote_server.id}
      else
        flash[:error] = result['message']
        format.html {render :action => 'new_dns'}
      end
    end

  end

  def delete_dns
    @remote_server = RemoteServer.find_by_id(params[:remote_server_id])
    
    @source = params[:source]
    @type = params[:type]
    @destination = params[:destination]

    result = @remote_server.delete_dns(@source, @type, @destination)

    respond_to do |format|
      if result && result['status'] == 'success'
        flash[:success] = _('DNS deleted successfully')
        format.html {redirect_to :action => 'show_dns_managements', :remote_servers_id => @remote_server.id}
      else
        flash[:error] = result['message']
        format.html {render :action => 'new_dns'}
      end
    end
  end

  def show_dns_managements
    @remote_server = RemoteServer.find_by_id(params[:remote_server_id])

    respond_to do |format|
      format.html # (en el caso de que el fichero que renderizas tenga nombre distinto al nombre de la action){render => <nombre fichero>}
    end
  end

end
