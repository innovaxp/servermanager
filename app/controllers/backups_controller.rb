class BackupsController < ApplicationController
	# GET /backups
	# GET /backups.json
	def index
	
		@backup_configuration = BackupConfiguration.find_by_id_and_owner_id(params[:backup_configuration_id],session[:owner_id])
		if @backup_configuration
			@backups = Backup.find_all_by_backup_configuration_id(@backup_configuration.id, :order => 'created_at DESC')
		else
			@backups = Array.new
		end
		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: @backups }
		end
	end

	# GET /backups/1
	# GET /backups/1.json
	def show
		@backup = Backup.find(params[:id])
		if @backup.backup_configuration.owner_id == session[:owner_id]
			respond_to do |format|
				format.html # show.html.erb
				format.json { render json: @backup }
			end
		else
			redirect_to backups_url
		end
	end

	def retry_backup
		@backup = Backup.find_by_id(params[:id])
		@backup.status = 'inprocess'
		@backup.save

		spawn_block(:argv => "spawn -backup-") do
      @backup.backup_configuration.run_backup(@backup)
    end
		
		respond_to do |format|
			format.html { redirect_to backups_url(:backup_configuration_id => @backup.backup_configuration.id), notice: _('Backup in process, you will be notified to the specified email addresses') }
		end
	end

	def retry_upload
		@backup = Backup.find_by_id(params[:id])
		@backup.status = 'uploading'
		@backup.save

		spawn_block(:argv => "spawn -backup-") do
			@backup.backup_configuration.upload_backup(@backup)
		end

		respond_to do |format|
			format.html { redirect_to backups_url(:backup_configuration_id => @backup.backup_configuration.id), notice: _('Backup upload in process, you will be notified to the specified email addresses') }
		end
	end


  def list_historical_backup
    @database = params['database']
    @backup_configuration = BackupConfiguration.find_by_id_and_owner_id(params[:backup_configuration_id],session[:owner_id])

    if @backup_configuration
      @backups =  @backup_configuration.has_finished_backups_for_db(@database)
		else
			@backups = Array.new
		end



		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: @backups }
		end

    end
    
    def restore_backup
      @database = params['database']
      @backup_configuration = BackupConfiguration.find_by_id_and_owner_id(params[:backup_configuration_id],session[:owner_id])
      @backup = Backup.find_by_id(params[:backup])
      
      spawn_block(:argv => "spawn -backup_restore-") do
        @backup.restore(@database)
      end
      
      respond_to do |format|
        format.html { redirect_to backups_url(:backup_configuration_id => params[:backup_configuration_id]), notice: sprintf(_('Backup for %s successfully restored to the status dated on %s'), params['database'], @backup.created_at.strftime('%d-%m-%Y %H:%M:%S')) }
      end
      
    end
    
    def upload_finished_callback
      backup = Backup.find_by_id(params['meta']['backup_id'])
      
      if backup
        if params['transfer'] && params['transfer'].has_key?('url') && params['transfer']['url'] && params['transfer']['url'] != ''
          if !backup.meta
            backup.meta = Hash.new
            backup.meta['url'] = Hash.new
          end
          
          backup.meta['url'][params['meta']['db_name']] = params['transfer']['url']
        end
        
        backup.remaining_uploads = backup.remaining_uploads - 1
        backup.save
        
        if backup.remaining_uploads <= 0
          backup.backup_configuration.backup_finished(backup)
          
      		if backup.status == 'finished'
      			backup.backup_configuration.notify_to.each do |email_address|
      				BackupMailer.success(backup, email_address).deliver
      			end
      		else
      			backup.backup_configuration.notify_to.each do |email_address|
      				BackupMailer.failed_upload(backup, email_address).deliver
      			end
      		end
          
        end
        
      end
      
      response = { :result => 'OK'}
      
      respond_to do |format|
        format.html { render :text => 'OK' }
        format.xml { render :xml => response.to_xml }
      end
      
    end
    

	# GET /backups/new
	# GET /backups/new.json
	#  def new
	#    @backup = Backup.new
	#
	#    respond_to do |format|
	#      format.html # new.html.erb
	#      format.json { render json: @backup }
	#    end
	#  end

	# GET /backups/1/edit
	#  def edit
	#    @backup = Backup.find(params[:id])
	#  end

	# POST /backups
	# POST /backups.json
	#  def create
	#    @backup = Backup.new(params[:backup])
	#
	#    respond_to do |format|
	#      if @backup.save
	#        format.html { redirect_to @backup, notice: 'Backup was successfully created.' }
	#        format.json { render json: @backup, status: :created, location: @backup }
	#      else
	#        format.html { render action: "new" }
	#        format.json { render json: @backup.errors, status: :unprocessable_entity }
	#      end
	#    end
	#  end
	#
	#  # PUT /backups/1
	#  # PUT /backups/1.json
	#  def update
	#    @backup = Backup.find(params[:id])
	#
	#    respond_to do |format|
	#      if @backup.update_attributes(params[:backup])
	#        format.html { redirect_to @backup, notice: 'Backup was successfully updated.' }
	#        format.json { head :no_content }
	#      else
	#        format.html { render action: "edit" }
	#        format.json { render json: @backup.errors, status: :unprocessable_entity }
	#      end
	#    end
	#  end

	# DELETE /backups/1
	# DELETE /backups/1.json
	#  def destroy
	#    @backup = Backup.find(params[:id])
	#    @backup.destroy
	#
	#    respond_to do |format|
	#      format.html { redirect_to backups_url }
	#      format.json { head :no_content }
	#    end
	#  end
end
