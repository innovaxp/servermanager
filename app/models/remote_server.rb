class RemoteServer < ActiveRecord::Base
	require 'net/ssh'

	validates_uniqueness_of :path, :scope => :host

  validates_confirmation_of :password

  serialize :meta
  
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :root_remote_server, :class_name => "RemoteServer", :foreign_key => "root_remote_server_id"
  has_many :account_remote_servers, :class_name => "RemoteServer", :foreign_key => "root_remote_server_id"

	before_save :remove_protocol
	has_many :working_copies
  has_many :backup_configurations

  def self.get_types
    return {
      'RemoteServer' => _('No type'),
      'RootRemoteServer' => _('Root'),
      'AccountRemoteServer' => _('Account')
    }
  end

	def remove_protocol
		if self.host =~ /https?:\/\//
			self.host.gsub!(/https?:\/\//, '')
		end
	end

	def pretty_description
		return self.description + " ("+self.user+"@"+self.host+"/"+self.path+") "
	end

	def start_session
    begin
		  return Net::SSH.start(self.host, self.user, :password => self.password, :verbose => :debug)
    rescue Net::SSH::AuthenticationFailed
      return { :error_message => _('Authentication failed when accessing the server'), :object => RemoteServer.find(:first, :conditions => [ "host = ? AND user = ?", self.host, self.user ]) }
    end
	end

  def get_clean_domain

    if self.host =~ /([a-z0-9]*?\.){2}/i
      #tiene subdominio (www.dominio.com)
      @clean_host = self.host.sub(/[a-z0-9]*?\./,'')
    else
      #no tiene subdominio (dominio.com)
      @clean_host = self.host
    end

  end

	def end_session(session)
		session.close unless session.nil?
	end

	def run_command(command, session, as_sudo)
		command_result = ''

		sshlogger = Logger.new(Rails.root.to_s+"/log/ssh.log")

		channel = session.open_channel do |channel|
			channel.request_pty do |ch , success|
				raise "I can't get pty rquest" unless success

				if as_sudo
					ch.exec(RemoteServer.command_as_sudo(command, self.password))
				else
					ch.exec("[ -f ~/.bashrc ] && source ~/.bashrc; [ -f ~/.profile ] && source ~/.profile; [ -f ~/.bash_profile ] && source ~/.bash_profile; "+command)
				end

				sshlogger.info "shell_prompt# "+command

				ch.on_data do |chd , data|
					data.inspect
					if !data.inspect.include? "[sudo]"
						command_result = command_result + data
					end

					sshlogger.info data

				end

			end
			session.loop
		end

		channel.wait
		return command_result
	end

	def self.command_as_sudo(command, password)
		return "echo \"#{password}\" | sudo -S #{command}"
	end

  def get_crons

    crons = Array.new

    if self.list_crons['status'] == 'success'
      self.list_crons['data']['list'].each do |cron|
        crons << cron
      end
    end
    
    return crons

  end

  #devuelve el numero de crons
  def get_count_crons
    return get_crons.count
  end

  def create_cron(cron, status)
    curr_session = self.start_session
    result = self.run_command("inn_ec2_manage_crons create #{status.to_s} \"#{cron}\" 2> /dev/null", curr_session, false)

    self.end_session(curr_session)

    if result =~ /\[E\]/i
      result = result.sub(/\[E\]/i,'')

      return {'status' => 'error', 'message' => result}
    else
      return {'status' => 'success'}
    end

  end
  

  def list_crons
    curr_session = self.start_session

    result = self.run_command("inn_ec2_manage_crons list #{self.get_clean_domain.strip} 2> /dev/null", curr_session, false)

    self.end_session(curr_session)

    result_hash = JSON.parse(result)
    result_data = Array.new  

    if result_hash['error']
      return {'status' => 'error', 'message' => result_hash['error']}
    else
      
      result_hash['data'].each do |cron_element|
        result_cron = Hash.new
        #es activo si (cron_element['date_fields'] =~ /^\#/).nil? (es nulo)
        result_cron['active'] = (cron_element['date_fields'] =~ /^\#/).nil?
        cron_element['date_fields'] = cron_element['date_fields'].sub(/^\#/,'')
        result_cron['date_fields'] = cron_element['date_fields'].split(' ')
        result_cron['command_field'] = cron_element['command_field']
        result_cron['line_n'] = cron_element['line_n']
        result_data << result_cron
      end
    end
    return {'status' => 'success', 'data' => {'list' => result_data}}

  end

  def toggle_cron_activation (line_n, status)
    
    curr_session = self.start_session

    result = self.run_command("inn_ec2_manage_crons #{status} #{line_n} 2> /dev/null", curr_session, false)

    self.end_session(curr_session)

    result_hash = JSON.parse(result)

    if result_hash['error']
      return {'status' => 'error', 'message' => result_hash['error']}
    else
      return {'status' => 'success'}
    end
  end

  def delete_cron (line_n)

    curr_session = self.start_session

    result = self.run_command("inn_ec2_manage_crons delete #{line_n} 2> /dev/null", curr_session, false)

    self.end_session(curr_session)

    result_hash = JSON.parse(result)

    if result_hash['error']
      return {'status' => 'error', 'message' => result_hash['error']}
    else
      return {'status' => 'success'}
    end
    
  end

  #DNS
  #
  #Lista los dns que tenemos
  def list_dnss(list)
    curr_session = self.start_session

    result = self.run_command("inn_ec2_manage_crons list \"#{self.host}\" \"#{list}\" 2> /dev/null", curr_session, false)

    self.end_session(curr_session)

    result_hash = JSON.parse(result)

    if result_hash['error']
      return {'status' => 'error', 'message' => result_hash['error']}
    else
      return {'status' => 'success'}
    end
  end

  def delete_dns(source, type, destination)

    curr_session = self.start_session

    result = self.run_command("inn_ec2_manage_crons delete \"#{self.host}\" \"#{source}\" \"#{type}\" \"#{destination}\" 2> /dev/null", curr_session, false)
    
    self.end_session(curr_session)

    result_hash = JSON.parse(result)

    if result_hash['error']
      return {'status' => 'error', 'message' => result_hash['error']}
    else
      return {'status' => 'success'}
    end
  end

  def update_dns(source, type, destination, old_source, old_type, old_destination)
    curr_session = self.start_session
    result = self.run_command("inn_ec2_manage_crons update \"#{self.host}\" \"#{source}\" \"#{type}\" \"#{destination}\" \"#{old_source}\" \"#{old_type}\" \"#{old_destination}\" 2> /dev/null", curr_session, false)

    self.end_session(curr_session)

    if result =~ /\[E\]/i
      result = result.sub(/\[E\]/i,'')

      return {'status' => 'error', 'message' => result}
    else
      return {'status' => 'success'}
    end
  end

  def create_dns(source, type, destination)
    curr_session = self.start_session
    result = self.run_command("inn_ec2_manage_crons create \"#{self.host}\" \"#{source}\" \"#{type}\" \"#{destination}\" 2> /dev/null", curr_session, false)

    self.end_session(curr_session)

    if result =~ /\[E\]/i
      result = result.sub(/\[E\]/i,'')

      return {'status' => 'error', 'message' => result}
    else
      return {'status' => 'success'}
    end
  end

  def update_server_password(old_pass, new_pass)
    raise 'update_server_password'+ old_pass.to_s+'/'+ new_pass.to_s
  end


  def create_account_on_server (user, password, domain, type)
    # inn_ec2_create_account -u username -p password -t type -d domain
    # type = "php" | "rails"
    curr_session = self.start_session

    result = self.run_command("inn_ec2_create_account -u #{user} -p #{password} -t #{type} -d #{domain}2> /dev/null", curr_session, false)

    self.end_session(curr_session)

    raise 'create_account_on_server'+': '+ user.to_s+'/'+ password.to_s+'/'+domain.to_s+'/'+type.to_s
  end

end
