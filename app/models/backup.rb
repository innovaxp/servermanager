class Backup < ActiveRecord::Base

	belongs_to :backup_configuration
	serialize :meta
  serialize :tmp_files
  
  def restore(database)
    
		session = self.backup_configuration.remote_server.start_session

		if !self.backup_configuration.remote_server.path || self.backup_configuration.remote_server.path == ''
			self.backup_configuration.remote_server.path = '.'
		end

    self.backup_configuration.remote_server.run_command("mkdir -p ~/tmp/#{database}", session, false)
    self.backup_configuration.remote_server.run_command("cd ~/tmp/#{database}; wget #{self.meta["url"][database]}", session, false)
    self.backup_configuration.remote_server.run_command("gunzip ~/tmp/#{database}/#{File.basename(self.meta["url"][database])}", session, false)

		response = self.backup_configuration.remote_server.run_command("mysql --user='#{self.backup_configuration.db_user}' --password='#{self.backup_configuration.db_password}' #{database} < ~/tmp/#{database}/#{File.basename(self.meta["url"][database]).gsub(/\.gz$/, '')}", session, false)
		
		self.backup_configuration.remote_server.end_session(session)
    
  end

end
