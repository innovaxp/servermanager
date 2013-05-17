#encoding: UTF-8

class FileSearch

  require 'net/ssh'
  #require 'net/ssh/shell'

  def self.default_extensions
    ['php', 'html', 'htm', 'css', 'txt', 'rb', 'erb', 'htaccess', 'js'].join(',')
  end

  def self.search(folder, term, extensions, recursive, insensitive, remote_server)
    #folder = '/home/'+folder
    
    lines_bf_aft = 5

    extensions_arr = extensions.split(',')

    name_conditions_arr = Array.new

    extensions_arr.each do |ext|
      name_conditions_arr.push("-name '*."+ext.strip+"'")
    end

    name_conditions = name_conditions_arr.join(' -o ')

    results = Array.new

    rec_option = "-maxdepth 1"
    if recursive
      rec_option = ""
    end

    insens_option = ""
    if insensitive
      insens_option = "-i"
    end

    sess = FileSearch.start_session(remote_server)
		
    find_command = "find #{folder} #{rec_option} \\( #{name_conditions} \\) -exec grep -l #{insens_option} -n '#{term}' '{}' \\;"

    find_command_result = FileSearch.run_command(find_command, sess, remote_server, true)
    find_command_result = find_command_result.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)

    find_command_result.split('\n').each do |file_with_matches|
      file_with_matches = file_with_matches.strip
      
      if file_with_matches.index('.security') == nil
      
        grep_command = "grep -A #{lines_bf_aft} -B #{lines_bf_aft} -n #{insens_option} '#{term}' '#{file_with_matches}'"
        grep_command_result = FileSearch.run_command(grep_command, sess, remote_server, true)
      
        results.push(:filename => file_with_matches , :matches => grep_command_result.force_encoding("ISO-8859-1").encode("utf-8", replace: nil))
      end
    end

    FileSearch.end_session(sess)

    return results
  end
	
  def self.run_command(command, sess, remote_server, as_sudo)
		
    if !remote_server
      return FileSearch.local_command(command, as_sudo)
    else
      return remote_server.run_command(command, sess, as_sudo)
    end
		
  end

  def self.local_command(command, as_sudo)
    if as_sudo
      return %x{#{FileSearch.command_as_sudo(command, APP_CONFIG['sudo_password'])}}
    else
      return %x[#{command}]
    end
  end

  def self.command_as_sudo(command, password)
    Rails.logger.info("Running: "+"echo \"#{password}\" | sudo -S #{command}")
    
    return "export LANG=C; echo \"#{password}\" | sudo -E -S #{command}"
  end


  def self.remove_delimited(folder, extensions, recursive, insensitive, remote_server, start_del, end_del)
    #folder = '/home/'+folder

    extensions_arr = extensions.split(',')

    name_conditions_arr = Array.new

    extensions_arr.each do |ext|
      name_conditions_arr.push("-name '*."+ext.strip+"'")
      name_conditions_arr.push("-name '."+ext.strip+"'")
    end

    name_conditions = name_conditions_arr.join(' -o ')

    results = Array.new

    rec_option = "-maxdepth 1"
    if recursive
      rec_option = ""
    end

    insens_option = ""
    if insensitive
      insens_option = "-i"
    end

    sess = FileSearch.start_session(remote_server)
		
    find_command = "find #{folder} #{rec_option} \\( #{name_conditions} \\) -exec grep -l #{insens_option} -n '#{start_del}' '{}' \\;"
    #raise find_command
      
    find_command_result = FileSearch.run_command(find_command, sess, remote_server, true)
    #raise find_command_result.split(' ').to_s
    find_command_result.split('\n').each do |file_with_matches|
      file_with_matches = file_with_matches.strip
      
      cat_command = "cat '#{file_with_matches}'"
      cat_command_result = FileSearch.run_command(cat_command, sess, remote_server, true)
      
      # Use only if there are UTF-8 related errors
      #results.push(:filename => file_with_matches , :matches => cat_command_result.force_encoding("ISO-8859-1").encode("utf-8", replace: nil))
      results.push(:filename => file_with_matches , :matches => cat_command_result)
    end
      
    results.each do |result|
      # Remove PHP comments
      overwrite_command = "sed -n -i '' -e '1h;1!H;${;g;s/\\##{start_del}\\#.*\\#\\/#{end_del}\\#//g;p;}' '#{result[:filename]}'"
      cat_command_result = FileSearch.run_command(overwrite_command, sess, remote_server, true)
      #raise overwrite_command.to_s
      # Remove HTML-like comments
      overwrite_command = "sed -n -i '' -e '1h;1!H;${;g;s/<!--#{start_del}-->.*<!--\\/#{end_del}-->//g;p;}' '#{result[:filename]}'"
      cat_command_result = FileSearch.run_command(overwrite_command, sess, remote_server, true)
      # Remove JS comments
      overwrite_command = "sed -n -i '' -e '1h;1!H;${;g;s/\\/\\*#{start_del}\\*\\/.*\\/\\*\\/#{end_del}\\*\\///g;p;}' '#{result[:filename]}'"
      cat_command_result = FileSearch.run_command(overwrite_command, sess, remote_server, true)
      
      #clean_contents = result[:matches].gsub(/(<!--#{start_del}-->.*<!--\/#{end_del}-->)/, '')
      #clean_contents = clean_contents.gsub(/(\##{start_del}\#[^#]*\#\/#{end_del}\#)/, '')
      #raise clean_contents.to_s
        
      #overwrite_command = "cat > #{result[:filename]} <<EOL"+"\n"+clean_contents.gsub("$", "/$")+"\n"+"EOL"

      #cat_command_result = FileSearch.run_command(overwrite_command, sess, remote_server, true)

    end
      
    
    FileSearch.end_session(sess)
    
    return results
  end

  def self.start_session(remote_server)

    if remote_server
      return remote_server.start_session
    else
      return nil
    end
  end

  def self.end_session(sess)
    sess.close unless sess.nil?
  end

  def self.get_entries(folder)
    FileUtils.cd folder
    return FileList['*']
  end
  
  ## Method to detect outdated installations and notify the admin
  def self.detect_versions
    require "action_mailer" 
    
    notify_list = ["rubentrf@gmail.com", "mcumer@gmail.com"]
    
    command = "vdetect --server-scan | sed '1,/Vulnerable/d'"
    result = FileSearch.local_command(command, true)
    
    if result && result != ''
      FileMailer.outdated_versions(result, notify_list).deliver
    end
    
  end
  
end