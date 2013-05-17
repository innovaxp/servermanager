class AccountRemoteServer  < RemoteServer

  #devuelve un array con email_accounts
  def get_email_accounts
     
    email_accounts = Array.new

    if self.list_email_account['status'] == 'success'
      self.list_email_account['data']['list'].each do |email|
        email_accounts << email
      end
    end
#    email_accounts = [
#     {'account_name' => 'user23@dominio.com', 'password' => 'AAA'},
#     {'account_name' => 'user24@dominio.com', 'password' => 'BBB'},
#     {'account_name' => 'user25@dominio.com', 'password' => 'CCC'},
#     {'account_name' => 'user26@dominio.com', 'password' => 'DDD'}
#
#    ]
    return email_accounts

  end

  #devuelve array con email_forwarders
  def get_email_forwarders

    email_forwarders = Array.new
    
    if self.list_email_forward['status'] == 'success'
      self.list_email_forward['data']['list'].each do |email|
        email_forwarders << email
      end
    end

#    email_fordwarders = [
#      {'account_name' => 'user35@dominio.com', 'destination' => 'des@dominio.com'},
#      {'account_name' => 'user36@dominio.com', 'destination' => 'des1@dominio.com'},
#      {'account_name' => 'user37@dominio.com', 'destination' => 'des2@dominio.com'}
#    ]
    return email_forwarders
    
  end

  #devuelve el numero de email_acounts
  def get_count_email_accounts
    return get_email_accounts.count
  end

  #devuelve el numero de email_forwarders
  def get_count_email_forwarders
    return get_email_forwarders.count
  end

  def create_email_account(acc_address, pass)
    curr_session = self.start_session

    result = self.run_command("inn_ec2_adddovecotuser create #{acc_address.strip} '#{pass.strip}' 2> /dev/null", curr_session, true)

    self.end_session(curr_session)

    if result =~ /\[E\]/i
      result = result.sub(/\[E\]/i,'')

      return {'status' => 'error', 'message' => result}
    else
      return {'status' => 'success'}
    end
    
  end

  def update_email_account(acc_address, pass)
    curr_session = self.start_session

    result = self.run_command("inn_ec2_adddovecotuser update #{acc_address.strip} '#{pass.strip}' 2> /dev/null", curr_session, true)

    self.end_session(curr_session)

    if result =~ /\[E\]/i
      result = result.sub(/\[E\]/i,'')

      return {'status' => 'error', 'message' => result}
    else
      return {'status' => 'success'}
    end

  end

  def list_email_account
    begin
      curr_session = self.start_session

      result = self.run_command("inn_ec2_adddovecotuser list #{self.get_clean_domain.strip} 2> /dev/null", curr_session, true)

      self.end_session(curr_session)

      if result =~ /\[E\]/i
        result = result.sub(/\[E\]/i,'')

        return {'status' => 'error', 'message' => result}
      end
    rescue
        return {'status' => 'error', 'message' => _("Can't connect to server #{self.host}")}
    end
    list = Array.new
    result.split(',').each do |res|
      list << res +'@'+ self.get_clean_domain
    end

    return {'status' => 'success', 'data' => {'list' => list}}
    

  end

  def create_email_forward(from, to)
    curr_session = self.start_session

    result = self.run_command("inn_ec2_email_forwarders create #{from} '#{to}' 2> /dev/null", curr_session, true)

    self.end_session(curr_session)

    if result =~ /\[E\]/i
      result = result.sub(/\[E\]/i,'')

      return {'status' => 'error', 'message' => result}
    else
      return {'status' => 'success'}
    end

  end

  def delete_email_forward(from, to)
    curr_session = self.start_session

    result = self.run_command("inn_ec2_email_forwarders delete #{from} #{to} 2> /dev/null", curr_session, true)

    self.end_session(curr_session)

    if result =~ /\[E\]/i
      result = result.sub(/\[E\]/i,'')

      return {'status' => 'error', 'message' => result}
    else
      return {'status' => 'success'}
    end

  end

  def list_email_forward
    curr_session = self.start_session

    result = self.run_command("inn_ec2_email_forwarders list #{self.get_clean_domain.strip} 2> /dev/null", curr_session, true)

    self.end_session(curr_session)

    if result =~ /\[E\]/i
      result = result.sub(/\[E\]/i,'')

      return {'status' => 'error', 'message' => result}
    else

      

      lines = result.gsub("\r\n", '|').split('|')

      result_data = Hash.new

      lines.each do |line|
        components = line.split(':')

        redirections = components[1].strip.gsub(/[\s\t]*?/,'')

        if redirections.strip != ''

          result_data[components[0].strip] = redirections.split(',').map { |x| x.strip }
        end
      end
      
      return {'status' => 'success', 'data' => {'list' => result_data}}
    end

  end

  def delete_catch_all(to)
    curr_session = self.start_session

    result = self.run_command("inn_ec2_catch_all delete '*' #{to} 2> /dev/null", curr_session, true)

    self.end_session(curr_session)

    if result =~ /\[E\]/i
      result = result.sub(/\[E\]/i,'')

      return {'status' => 'error', 'message' => result}
    else
      return {'status' => 'success'}
    end

  end

  def create_catch_all( mail)
    raise "dentro de create_catch_all con dominio: "+self.host+', envia a: '+mail.to_s
    
    curr_session = self.start_session

    result = self.run_command("inn_ec2_catch_all add #{self.host} '#{mail}' 2> /dev/null", curr_session, true)

    self.end_session(curr_session)

    if result =~ /\[E\]/i
      result = result.sub(/\[E\]/i,'')

      return {'status' => 'error', 'message' => result}
    else
      return {'status' => 'success'}
    end
  end

  def gets_catch_all
    
    catch_all = Array.new

#    if self.list_catch_all['status'] == 'success'
#      self.list_catch_all['data']['list'].each do |catch|
#        catch_all << catch
#      end
#    end

    catch_all = ['user35@dominio.com', 'des@dominio.com', 'user36@dominio.com', 'des1@dominio.com','user37@dominio.com','des2@dominio.com']
    return catch_all
  end

  def list_catch_all(domain)
    curr_session = self.start_session

    result = self.run_command("inn_ec2_catch_all list #{domain} 2> /dev/null", curr_session, true)

    self.end_session(curr_session)

    if result =~ /\[E\]/i
      result = result.sub(/\[E\]/i,'')

      return {'status' => 'error', 'message' => result}
    else

      if result =~ /\[E\]/i
        result = result.sub(/\[E\]/i,'')

        return {'status' => 'error', 'message' => result}
      else
        return {'status' => 'success','data' => {'list' => result_data}}
      end
    end

  end

end