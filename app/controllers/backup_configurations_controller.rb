class BackupConfigurationsController < ApplicationController
	# GET /backup_configurations
	# GET /backup_configurations.json
  before_filter :set_section

  def set_section
    @section = 'backups'
  end

	def index

    if params[:remote_server_id]
      @remote_server = RemoteServer.find(params[:remote_server_id])
      #raise @remote_server.to_yaml
      @backup_configurations = BackupConfiguration.find(:all, :conditions => ['owner_id = ? AND remote_server_id = ? AND type=?', session[:owner_id], params[:remote_server_id], params[:type]])
      #raise @backup_configurations.to_yaml
      #raise 'params'+params[:type].to_s
      @type = params[:type]
      if params[:type] == 'FileBackupConfiguration'
        @title = sprintf(_("Listing files backups for %s"), @remote_server.host)
      else
        @title = sprintf(_("Listing data base backups for %s"), @remote_server.host)
      end
      #raise @backup_configurations.to_yaml
    else
      @backup_configurations = BackupConfiguration.find_all_by_owner_id(session[:owner_id])
      if params[:type] == 'FileBackupConfiguration'
        @title = _("Listing Files Backup Configurations")
      else
        @title = _("Listing Data Base Backup Configurations")
      end
    end
    
		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: @backup_configurations }
		end
	end

  
  def new_file_backup


    @account_remote_server = AccountRemoteServer.find_by_id(params[:remote_server_id])

		@backup_configuration = FileBackupConfiguration.new
    @remote_servers = RemoteServer.find(:all, :conditions => ['owner_id = ?', session[:owner_id]])

    @period_units = Hash.new()
		@period_units['day'] = 'd'
		@period_units['week'] = 'w'
		@period_units['month'] = 'm'
		@period_units['year'] = 'y'
    @backup_configuration.name = "backup_%Y-%m-%d-%H_%M_%S"
		@upload_services = UploadService.find_all_by_owner_id(session[:owner_id])

    if params[:remote_server_id]
      
      @remote_server = RemoteServer.find(params[:remote_server_id])
      #raise @remote_server.to_yaml
      @backup_configuration.remote_server_id = @remote_server.id
    end
		respond_to do |format|
			format.html # index.html.erb
			#format.json { render json: @backup_configurations }
		end
  end

  def new_database_backup
    @account_remote_server = AccountRemoteServer.find_by_id(params[:remote_server_id])

		@backup_configuration = DataBaseBackupConfiguration.new
    @remote_servers = RemoteServer.find(:all, :conditions => ['owner_id = ?', session[:owner_id]])

    @period_units = Hash.new()
		@period_units['day'] = 'd'
		@period_units['week'] = 'w'
		@period_units['month'] = 'm'
		@period_units['year'] = 'y'
    @backup_configuration.name = "backup_%Y-%m-%d-%H_%M_%S"
		@upload_services = UploadService.find_all_by_owner_id(session[:owner_id])

    if params[:remote_server_id]

      @remote_server = RemoteServer.find(params[:remote_server_id])
      #raise @remote_server.to_yaml
      @backup_configuration.remote_server_id = @remote_server.id
    end
		respond_to do |format|
			format.html # index.html.erb
			#format.json { render json: @backup_configurations }
		end
  end

  def edit_file_backup
    @account_remote_server = AccountRemoteServer.find_by_id(params[:remote_server_id])

		@backup_configuration = FileBackupConfiguration.find(params[:id])
    @remote_servers = RemoteServer.find(:all, :conditions => ['owner_id = ?', session[:owner_id]])
    #raise 'dentro de edit file backup'
    @period_units = Hash.new()
		@period_units['day'] = 'd'
		@period_units['week'] = 'w'
		@period_units['month'] = 'm'
		@period_units['year'] = 'y'
    @backup_configuration.name = "backup_%Y-%m-%d-%H_%M_%S"
		@upload_services = UploadService.find_all_by_owner_id(session[:owner_id])

    if params[:remote_server_id]

      @remote_server = RemoteServer.find(params[:remote_server_id])
      #raise @remote_server.to_yaml
      @backup_configuration.remote_server_id = @remote_server.id
    end
		respond_to do |format|
			format.html # index.html.erb
			#format.json { render json: @backup_configurations }
		end
  end

  def edit_database_backup
    @account_remote_server = AccountRemoteServer.find_by_id(params[:remote_server_id])

		@backup_configuration = DataBaseBackupConfiguration.find(params[:id])
    #raise @backup_configuration.to_yaml
    @remote_servers = RemoteServer.find(:all, :conditions => ['owner_id = ?', session[:owner_id]])
    #raise 'dentro de edit file backup'
    @period_units = Hash.new()
		@period_units['day'] = 'd'
		@period_units['week'] = 'w'
		@period_units['month'] = 'm'
		@period_units['year'] = 'y'
    @backup_configuration.name = "backup_%Y-%m-%d-%H_%M_%S"
		@upload_services = UploadService.find_all_by_owner_id(session[:owner_id])

    if params[:remote_server_id]

      @remote_server = RemoteServer.find(params[:remote_server_id])
      #raise @remote_server.to_yaml
      @backup_configuration.remote_server_id = @remote_server.id
    end
		respond_to do |format|
			format.html # index.html.erb
			#format.json { render json: @backup_configurations }
		end
  end

  def toggle_file_backup_activation
    #raise 'dentro de cron acivation'
    @backup_configuration = FileBackupConfiguration.find_by_id(params[:remote_server_id])
    #raise @backup_configuration.to_yaml
    
    @backup_configuration.active = !@backup_configuration.active
    @backup_configuration.save

    respond_to do |format|
        format.html {redirect_to request.referer}
    end

  end

  def toggle_database_backup_activation
    #raise 'dentro de cron acivation'
    @backup_configuration = DataBaseBackupConfiguration.find_by_id(params[:remote_server_id])
    #raise @backup_configuration.to_yaml

    @backup_configuration.active = !@backup_configuration.active
    @backup_configuration.save

    respond_to do |format|
        format.html {redirect_to request.referer}
    end

  end

	# GET /backup_configurations/1
	# GET /backup_configurations/1.json
	def show
		@backup_configuration = BackupConfiguration.find_by_id_and_owner_id(params[:id],session[:owner_id])
		if @backup_configuration
			respond_to do |format|
				format.html # show.html.erb
				format.json { render json: @backup_configuration }
			end
		else
			redirect_to backup_configurations_url
		end
	end

	# GET /backup_configurations/new
	# GET /backup_configurations/new.json
	def new
		@backup_configuration = BackupConfiguration.new
    
    if params[:remote_server_id]
      @remote_server = RemoteServer.find(params[:remote_server_id])
      @backup_configuration.remote_server_id = @remote_server.id
    end
    #raise @remote_server.to_yaml
		@remote_servers = RemoteServer.find_all_by_owner_id(session[:owner_id])
    #raise @remote_servers.to_yaml
		@period_units = Hash.new()
		@period_units['day'] = 'd'
		@period_units['week'] = 'w'
		@period_units['month'] = 'm'
		@period_units['year'] = 'y'
    @backup_configuration.name = "backup_%Y-%m-%d-%H_%M_%S"
		@upload_services = UploadService.find_all_by_owner_id(session[:owner_id])

		respond_to do |format|
			format.html # new.html.erb
			format.json { render json: @backup_configuration }
		end
	end

	# GET /backup_configurations/1/edit
	def edit
		@backup_configuration = BackupConfiguration.find_by_id_and_owner_id(params[:id],session[:owner_id])
    #raise @backup_configuration.to_yaml
		if @backup_configuration
			@remote_servers = RemoteServer.find_all_by_owner_id(session[:owner_id])
			@period_units = Hash.new()
			@period_units['day'] = 'd'
			@period_units['week'] = 'w'
			@period_units['month'] = 'm'
			@period_units['year'] = 'y'
			@upload_services = UploadService.find_all_by_owner_id(session[:owner_id])
		else
			redirect_to backup_configurations_url
		end
	end

	# POST /backup_configurations
	# POST /backup_configurations.json
	def create

    #raise request.referer
    if params[:backup_configuration][:type] && params[:backup_configuration][:type] != ''
      type = params[:backup_configuration][:type]
      params[:backup_configuration].delete(:type)
    else
      type = 'BackupConfiguration'
    end

		@backup_configuration = eval(type).new(params[:backup_configuration])
		@remote_servers = RemoteServer.find_all_by_owner_id(session[:owner_id])
		@backup_configuration.owner_id = session[:owner_id]
		@period_units = Hash.new()
		@period_units['day'] = 'd'
		@period_units['week'] = 'w'
		@period_units['month'] = 'm'
		@period_units['year'] = 'y'

		@notifys = Array.new
		@notifys = params[:backup_configuration][:notify_to_cs].split(',')
		@notifys_final = Array.new
		@notifys.each do |notify|
			@notifys_final.push(notify.gsub(/\s+/, ""))
		end
		if @notifys_final.size > 0
			@backup_configuration.notify_to = @notifys_final
		end
		@upload_services = UploadService.find_all_by_owner_id(session[:owner_id])

    @remote_server = @backup_configuration.remote_server

    Alert.send_notification('backup_configuration', @backup_configuration , @remote_server)

		respond_to do |format|
			if @backup_configuration.save
        
        format.html {redirect_to :action => 'index', :remote_server_id => @backup_configuration.remote_server.id, :type => type}
        
				format.json { render json: @backup_configuration, status: :created, location: @backup_configuration }
			else
        
        if type == 'FileBackupConfiguration'
          dest = "new_file_backup"
        else
          dest = "new_database_backup"
        end


				format.html { render action: dest }
				format.json { render json: @backup_configuration.errors, status: :unprocessable_entity }
			end
		end
	end

	# PUT /backup_configurations/1
	# PUT /backup_configurations/1.json
	def update

    if params[:backup_configuration][:type] && params[:backup_configuration][:type] != ''
      type = params[:backup_configuration][:type]
      params[:backup_configuration].delete(:type)
    else
      type = 'BackupConfiguration'
    end
    if params[:remote_server_id]
      @backup_configurations = BackupConfiguration.find(:all, :conditions => ['owner_id = ? AND remote_server_id = ? AND type=?', session[:owner_id], params[:remote_server_id], params[:type]])
    else
      @backup_configurations = BackupConfiguration.find_all_by_owner_id(session[:owner_id])
    end
    
		@period_units = Hash.new()
		@period_units['day'] = 'd'
		@period_units['week'] = 'w'
		@period_units['month'] = 'm'
		@period_units['year'] = 'y'
    
		@backup_configuration = eval(type).find(params[:id])
    #raise @backup_configuration.to_yaml
		@remote_servers = RemoteServer.find_all_by_owner_id(session[:owner_id])
		@upload_services = UploadService.find_all_by_owner_id(session[:owner_id])

		@notifys = Array.new
		@notifys = params[:backup_configuration][:notify_to_cs].split(',')
		@notifys_final = Array.new
		@notifys.each do |notify|
			@notifys_final.push(notify.gsub(/\s+/, ""))
      
		end
		if @notifys_final.size > 0
			@backup_configuration.notify_to = @notifys_final
		end
		respond_to do |format|
			if @backup_configuration.update_attributes(params[:backup_configuration])
				format.html { redirect_to :action => 'index', :remote_server_id => @backup_configuration.remote_server.id, :type => type, :notice => _('Backup configuration was successfully updated.') }
				format.json { head :no_content }
			else
        #raise 'else'
				format.html { render action: "edit" }
				format.json { render json: @backup_configuration.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /backup_configurations/1
	# DELETE /backup_configurations/1.json
	def destroy
		@backup_configuration = BackupConfiguration.find_by_id_and_owner_id(params[:id],session[:owner_id])
		if @backup_configuration
			@backup_configuration.destroy

			respond_to do |format|
				format.html { redirect_to request.referer }
				format.json { head :no_content }
			end
		else
			redirect_to backup_configurations_url
		end
	end

	def run_backup
		@backup_configuration = BackupConfiguration.find_by_id_and_owner_id(params[:id],session[:owner_id])

		if @backup_configuration
			spawn_block(:argv => "spawn -backup-") do
				@backup_configuration.run_backup
      end
		end

		respond_to do |format|
			format.html { redirect_to backup_configurations_url, notice: _('Backup in process, you will be notified to the specified email addresses') }
		end
	end
  
  def get_user_databases
    
    @backup_configuration = BackupConfiguration.new
    @backup_configuration.db_user = params['user']
    @backup_configuration.db_password = params['password']
    
    @remote_server = RemoteServer.find_by_id(params['remote_server_id'])
    
    @backup_configuration.remote_server = @remote_server
    
    db_list = @backup_configuration.get_user_databases.split(/\W+/)

    db_hash = Hash.new
 
    if !params['databases'] && db_list && db_list.size > 0
      db_list.each do |db|
        db_hash[db] = 'unchecked'
      end
    elsif params['databases'] && db_list.size() == params['databases'].size()
      db_list.each do |db|
        db_hash[db] = 'checked'
      end
    elsif params['databases'] && db_list
      db_list.each do |db|
        if params['databases'].include?(db)
          db_hash[db] = 'checked'
        else
          db_hash[db] = 'unchecked'
        end
      end
    end

    respond_to do |format|
      format.json { render json: db_hash}
      format.js { render json: db_hash}
      format.html
    end
  end

end
