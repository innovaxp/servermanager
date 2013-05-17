class WorkingCopy < ActiveRecord::Base
	require 'net/ssh'

	belongs_to :repository
	belongs_to :remote_server

	attr_reader :remote_server_description
	attr_reader :svn_flags
	attr_reader :class_for_flag

	serialize :flags

  def self.wc_types
    wc_types = ['Test', 'Production']
    return wc_types
  end


	def svn_flags

		additional = ''

		if self.repository.user && self.repository.password
			additional = "--username '"+self.repository.user+"' --password '"+self.repository.password+"'"
		end

		return  "--non-interactive --trust-server-cert #{additional}"
	end

	def remote_server_description
		return self.remote_server.description.to_s + " ("+self.remote_server.host.to_s+"/"+(self.remote_server.path.to_s != '' ? self.remote_server.path.to_s+"/" : "")+self.wc_location.to_s+")"
	end

	def class_for_flag(flag)
		if !self.flags || !self.flags.has_key?(flag)
			return "grey"
		end

		if self.flags[flag]
			return "red"
		else
			return "green"
		end

	end

	def self.types
		all_ty = Hash.new
		all_ty['PhpWorkingCopy'] = 'PHP'
		all_ty['RailsWorkingCopy'] = 'Ruby on Rails'

		return all_ty
	end

	def checkout
		session = self.remote_server.start_session

		if !self.remote_server.path || self.remote_server.path == ''
			self.remote_server.path = '.'
		end

		self.remote_server.run_command("mkdir -p #{self.remote_server.path}/#{self.wc_location}", session, true)
		self.remote_server.run_command("chown -R #{self.remote_server.user}:#{self.remote_server.user} #{self.remote_server.path}/#{self.wc_location}", session, true)
		result = self.remote_server.run_command("svn co #{self.svn_flags} svn://#{APP_CONFIG['server_url']}/#{self.repository.slave_location}/#{self.location.to_s} #{self.remote_server.path}/#{self.wc_location}", session, false)
		
		self.remote_server.end_session(session)

		self.detect_changes(result)

		self.last_update_date = DateTime.now
		self.check_svn_status
	end

	def update_wc
		session = self.remote_server.start_session
    
    if session && session.class == Net::SSH::Connection::Session
  		if !self.remote_server.path || self.remote_server.path == ''
  			self.remote_server.path = '.'
  		end

  		result = self.remote_server.run_command("svn up #{self.svn_flags} #{self.remote_server.path}/#{self.wc_location}", session, false)

  		#raise result

  		self.remote_server.end_session(session)

  		self.detect_changes(result)

  		self.last_update_date = DateTime.now
  		self.check_svn_status
      
      return true
    else
      return session
    end
	end

	def rollback_wc(version)

		if !version || version.to_i == 0
			version = self.last_revision
		end

		session = self.remote_server.start_session

		if !self.remote_server.path || self.remote_server.path == ''
			self.remote_server.path = '.'
		end

		self.remote_server.run_command("svn cleanup #{self.remote_server.path}/#{self.wc_location}", session, false)

		# Resolve possible conflicts: revert files
		status = self.remote_server.run_command("svn stat #{self.svn_flags} --xml #{self.remote_server.path}/#{self.wc_location}", session, false)

		repo_status = XmlSimple.xml_in(status, { 'ForceArray' => false })["target"]

		if repo_status["entry"]

			if !repo_status["entry"].kind_of?(Array)
				repo_status["entry"] = [ repo_status["entry"] ]
			end

			repo_status["entry"].each do |entry|
				if entry["wc-status"]["item"] == 'conflicted'
					self.remote_server.run_command("svn revert #{entry["path"]}", session, false)
				end
			end
		end
		# End Resolve conflicts

		result = self.remote_server.run_command("svn up --revision #{version} #{self.svn_flags} #{self.remote_server.path}/#{self.wc_location}", session, false)

		#raise result

		self.remote_server.end_session(session)

		self.detect_changes(result)

		self.last_update_date = DateTime.now
		self.check_svn_status
	end

	def check_svn_status
		require 'xmlsimple'

		if self.current_revision.to_i > 0
			curr_rev = self.current_revision
		else
			curr_rev = 0
		end

		session = self.remote_server.start_session

		if !self.remote_server.path || self.remote_server.path == ''
			self.remote_server.path = '.'
		end

		result = self.remote_server.run_command("svn info #{self.svn_flags} --xml #{self.remote_server.path}/#{self.wc_location}", session, false)
		status = self.remote_server.run_command("svn stat #{self.svn_flags} --xml #{self.remote_server.path}/#{self.wc_location}", session, false)

		self.remote_server.end_session(session)

		repo_info = XmlSimple.xml_in(result, { 'ForceArray' => false })["entry"]

		repo_status = XmlSimple.xml_in(status, { 'ForceArray' => false })["target"]

		if ! repo_status["entry"]
			self.status = "ok"
		else
			if !repo_status["entry"].kind_of?(Array)
				repo_status["entry"] = [ repo_status["entry"] ]
			end

			self.status = "ok"

			repo_status["entry"].each do |entry|
				if entry["wc-status"]["item"] == 'deleted' || entry["wc-status"]["item"] == 'conflicted'
					self.status = "error"
				end
			end
		end

		self.current_revision = repo_info['revision'].to_i

		if self.current_revision > curr_rev.to_i
			self.last_revision = curr_rev
		end

		if curr_rev == 0
			self.last_revision = self.current_revision
		end
		
	end

	def detect_changes(result)
		# Dummy method, implement on subclases
	end

  def get_log(lines)
    log = ''
    if self.type == 'RailsWorkingCopy'
      session = self.remote_server.start_session     
      log = self.remote_server.run_command("tail -n#{lines} #{self.remote_server.path}/#{self.wc_location}/log/production.log", session, false)     
      self.remote_server.end_session(session)
    end    
    return log
  end

end
