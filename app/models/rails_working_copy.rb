class RailsWorkingCopy < WorkingCopy
	set_table_name 'working_copies'

	def precompile_as
		session = self.remote_server.start_session

		if !self.remote_server.path || self.remote_server.path == ''
			self.remote_server.path = '.'
		end

		result = self.remote_server.run_command("cd #{self.remote_server.path}/#{self.wc_location} && rake assets:precompile", session, false)

		self.remote_server.end_session(session)

		if !self.flags
			self.flags = Hash.new
		end
		
		self.flags["assets"] = false
		self.save

		return result
	end

	def db_migrate
		session = self.remote_server.start_session

		if !self.remote_server.path || self.remote_server.path == ''
			self.remote_server.path = '.'
		end

		result = self.remote_server.run_command("cd #{self.remote_server.path}/#{self.wc_location} && rake db:migrate", session, false)

		self.remote_server.end_session(session)

		if !self.flags
			self.flags = Hash.new
		end

		self.flags["migrate"] = false
		self.save

		return result
	end

	def serv_restart
		session = self.remote_server.start_session

		if !self.remote_server.path || self.remote_server.path == ''
			self.remote_server.path = '.'
		end

		result = self.remote_server.run_command("touch #{self.remote_server.path}/#{self.wc_location}/tmp/restart.txt && echo 'Passenger server restarted successfully'", session, false)

		self.remote_server.end_session(session)

		if !self.flags
			self.flags = Hash.new
		end

		if !self.flags["assets"] && !self.flags["migrate"] && !self.flags["bundle"]
			self.flags["restart"] = false
			self.save
		end

		return result
	end

	def bundle_install
		session = self.remote_server.start_session

		if !self.remote_server.path || self.remote_server.path == ''
			self.remote_server.path = '.'
		end

		result = self.remote_server.run_command("cd #{self.remote_server.path}/#{self.wc_location} && bundle install", session, false)

		self.remote_server.end_session(session)

		if !self.flags
			self.flags = Hash.new
		end

		self.flags["bundle"] = false
		self.save

		return result

	end


	def detect_changes(result)

		if !self.flags
			self.flags = Hash.new
		end

		# Find changes on assets
		if !result.index("assets").nil?
			self.flags["assets"] = true
		else
			self.flags["assets"] = false
		end

		# Find changes on migrations
		if !result.index("migrate").nil?
			self.flags["migrate"] = true
		else
			self.flags["migrate"] = false
		end

		# Find changes on gems
		if !result.index("Gemfile").nil?
			self.flags["bundle"] = true
		else
			self.flags["bundle"] = false
		end

		if self.flags["assets"] || self.flags["migrate"] || self.flags["bundle"]
			self.flags["restart"] = true
		else
			self.flags["restart"] = false
		end

	end

end
