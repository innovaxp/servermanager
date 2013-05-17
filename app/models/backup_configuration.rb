class BackupConfiguration < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
	belongs_to :remote_server
	belongs_to :upload_service
	has_many :backups
	serialize :notify_to
  serialize :databases

	validates :period_number, :presence => true

	attr_accessor :notify_to_cs

  def last_successfully_backup
    
    if self.backups.count > 0
      backups = self.backups.delete_if{|x| x.status != 'finished'}
      if backups && backups.count > 0
        return backups.last
      else
        return nil
      end
    else return nil
    end
  end


  def has_finished_backups_for_db(db_name)
    tmp_backups = self.backups.all(:order => 'created_at DESC')
    backups = Array.new
    tmp_backups.each do |tmp|

      if tmp.meta && tmp.meta.kind_of?(Hash) && tmp.meta.has_key?('url') && tmp.meta['url'].kind_of?(Hash) && tmp.meta['url'].has_key?(db_name) && /https?:/.match(tmp.meta['url'][db_name])
        backups.push(tmp)
      end
    end

    return backups
  end


	def notify_to_cs
		if self.notify_to
			return self.notify_to.join(',')
		else
			return ''
		end
	end

	def needs_backup?

		if !self.active
			return false
		else
			if self.sucesfully_backups && self.sucesfully_backups.kind_of?(Array) && self.sucesfully_backups.count > 0
				last_backup = self.sucesfully_backups.last

				case self.period_unit
				when 'd'
					if self.period_number == 1
						compare_time = Time.now - 1.day
					else
						compare_time = Time.now - self.period_number.days
					end
				when 'w'
					if self.period_number == 1
						compare_time = Time.now - 1.week
					else
						compare_time = Time.now - self.period_number.weeks
					end
				when 'm'
					if self.period_number == 1
						compare_time = Time.now - 1.month
					else
						compare_time = Time.now - self.period_number.months
					end
				when 'y'
					if self.period_number == 1
						compare_time = Time.now - 1.year
					else
						compare_time = Time.now - self.period_number.years
					end
				end

				if last_backup.created_at - 5.hours <= compare_time
					return true
				else
					return false
				end
			else
				return true
			end
		end

		
	end

	def sucesfully_backups
		return self.backups.find_all_by_status('finished', :order => 'created_at ASC')
	end

	def perform_backup(backup = nil)

		session = self.remote_server.start_session

		if !self.remote_server.path || self.remote_server.path == ''
			self.remote_server.path = '.'
		end
    
    response_data = Hash.new
    
    self.databases.each do |database|
      if backup.nil? || backup.tmp_files.nil? || (backup.tmp_files.kind_of?(Hash) && backup.tmp_files.count == 0) || (backup && backup.tmp_files && backup.tmp_files.has_key?('url') && backup.tmp_files['url'].has_key?(database) && backup.tmp_files['url'][database] == 'EE')
        file_name = File.basename(self.name).gsub('%dbname', database)

        file_name = "#{Time.now.strftime(file_name)}.sql.gz"

        self.remote_server.run_command("mkdir -p #{self.local_folder}", session, false)
        response = self.remote_server.run_command("mysqldump -f --user='#{self.db_user}' --password='#{self.db_password}' #{database} | gzip > #{self.local_folder}/#{file_name}", session, false)

        if response.to_s.index("error") != nil && response.to_s.index("LOCK TABLES").nil?
          response_data[database] = 'EE'
        else
          response_data[database] = file_name
        end
      end
    end

		self.remote_server.end_session(session)

		return response_data

	end

	def upload_backup(backup)
    
    response = Hash.new
    
    backup.remaining_uploads = backup.tmp_files.select {|k,v| v != 'EE'}.count
    backup.save
    
    backup.tmp_files.each do |db_name, tmp_file|
      if tmp_file != 'EE'
        url = self.local_folder_url+'/'+tmp_file

        # Set the new path
        relative_path = File.dirname(self.name).gsub('%dbname', db_name)
    		relative_path = "#{Time.now.strftime(relative_path)}"
      
        current_path = self.upload_service.meta["path"].clone
      
        if !current_path 
          current_path = ''
        end
      
        if current_path[-1] != '/'
          current_path = current_path + '/'
        end
      
        current_path = current_path + relative_path

        params_hash = Hash.new
        params_hash['source'] = Hash.new
        params_hash['source']['type'] = 'url'
        params_hash['source']['meta'] = {'url' => url, 'name' => File.basename(url)}

        params_hash['destination'] = Hash.new
        params_hash['destination']['type'] = self.upload_service.location.downcase
        params_hash['destination']['meta'] = self.upload_service.meta.clone
        params_hash['destination']['meta']['path'] = current_path

        params_hash['meta'] = Hash.new
        params_hash['meta']['backup_id'] = backup.id
        params_hash['meta']['db_name'] = db_name
        params_hash['meta']['callback_url'] = url_for({ :controller => 'backups', :action => 'upload_finished_callback'})

        #raise "Calling API on: "+APP_CONFIG["transfer_service_url"]+"/transfers/api_transfer.xml?api_user="+APP_CONFIG["transfer_service_api_user"]+"&api_key="+APP_CONFIG["transfer_service_api_key"]+"&"+params_hash.to_query
        Rails.logger.info("Calling API on: "+APP_CONFIG["transfer_service_url"]+"/transfers/api_transfer.xml?api_user="+APP_CONFIG["transfer_service_api_user"]+"&api_key="+APP_CONFIG["transfer_service_api_key"]+"&"+params_hash.to_query)

        begin
          uploaded_data = HTTParty.get(APP_CONFIG["transfer_service_url"]+"/transfers/api_transfer.xml?api_user="+APP_CONFIG["transfer_service_api_user"]+"&api_key="+APP_CONFIG["transfer_service_api_key"]+"&"+params_hash.to_query)
          uploaded_url = 'IP'
        rescue
          backup.remaining_uploads = backup.remaining_uploads - 1 
          backup.save
          uploaded_url = 'EE'
        end
        
      else
        uploaded_url = 'EE'
      end

      response[db_name] = uploaded_url
    end
    
		return response
	end

	def delete_local_backup(backup)
		session = self.remote_server.start_session

		if !self.remote_server.path || self.remote_server.path == ''
			self.remote_server.path = '.'
		end
    
    backup.tmp_files.each do |db_name,tmp_file|
      if tmp_file != 'EE'
        self.remote_server.run_command("rm #{self.local_folder}/#{tmp_file}", session, false)
      end
    end

		self.remote_server.end_session(session)

	end

	def run_backup(backup_id = nil)
		require "action_mailer"
    
		if !backup_id
			backup = Backup.create(:status => 'inprocess')
			self.backups.push(backup)

      backup.tmp_files = self.perform_backup
		else
			backup = Backup.find_by_id(backup_id)
			backup.status = 'inprocess'
			backup.save
      backup.tmp_files = self.perform_backup(backup)
		end
		

    backup.status = 'failed'
    
    backup.tmp_files.each do |key,value|
      if value == 'EE'
        backup.meta = {key+'_status' => _('Error in this DB') }

      else
        backup.status = 'inprocess'
      end
    end
    
    backup.save
    
		if backup.status != 'failed'

			transfer_data = self.upload_backup(backup)

		else
			self.notify_to.each do |email_address|
				BackupMailer.failed(backup, email_address).deliver
			end
		end



	end
  
  def get_user_databases
		session = self.remote_server.start_session

		if !self.remote_server.path || self.remote_server.path == ''
			self.remote_server.path = '.'
		end

		response = self.remote_server.run_command("mysql --user='#{self.db_user}' --password='#{self.db_password}' -Bse 'show databases'", session, false)
		
		self.remote_server.end_session(session)
    
    if response =~ /ERROR/
      return ''
    end
    
    return response
  end

	def self.run_backups
		back_confs = BackupConfiguration.find(:all)

		back_confs.each do |back_conf|
			if back_conf.needs_backup?
				back_conf.run_backup
			end
		end

	end
  
  def backup_finished(backup)
    backup.status = 'finished'

    backup.tmp_files.each do |key, value|
      if !value || value == '' || value == 'EE'
        backup.status = 'finished_with_errors'
      end
    end
      
    self.delete_local_backup(backup)
      
		backup.save

  end
  
end
