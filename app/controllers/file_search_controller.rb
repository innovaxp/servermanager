class FileSearchController < ApplicationController
	before_filter :authorize

  before_filter :set_section

  def set_section
    if params[:action]
      @section = params[:action]+'files'
    else
      @section = 'searchfiles'
    end
  end

	def search

    

		@results = nil
		@dir_contents = nil

		@remote_servers = RemoteServer.find(:all)

		@selected_server = nil

		@no_text = _('No matches found')

		if params["local"]
			@selected_tab = 'local'
		elsif params["remote"]
			@selected_tab = 'remote'
			@selected_server = RemoteServer.find_by_id(params["remote_servers"])
		else
			@selected_tab = 'local'
			@no_text = ''
		end
		

		if params["local"] || params["remote"]
			@results = FileSearch.search(params[:folder], params[:term], params[:extensions], params[:recursive], params[:insensitive], @selected_server)

			#@dir_contents = FileSearch.get_entries(params[:folder])
			@dir_contents = Array.new
		end

		@def_extensions = FileSearch.default_extensions

		respond_to do |format|
			format.html
			format.xml { head :ok }
		end
	end
  
	def replace

		@results = nil
		@dir_contents = nil

		@remote_servers = RemoteServer.find(:all)

		@selected_server = nil

		@no_text = _('No matches found')

		if params["local"]
			@selected_tab = 'local'
		elsif params["remote"]
			@selected_tab = 'remote'
			@selected_server = RemoteServer.find_by_id(params["remote_servers"])
		else
			@selected_tab = 'local'
			@no_text = ''
		end
		

		if params["local"] || params["remote"]
			@results = FileSearch.remove_delimited(params[:folder], params[:extensions], params[:recursive], params[:insensitive], @selected_server, params[:start_del], params[:end_del])

			#@dir_contents = FileSearch.get_entries(params[:folder])
			@dir_contents = Array.new
		end

		@def_extensions = FileSearch.default_extensions

		respond_to do |format|
			format.html
			format.xml { head :ok }
		end
	end
  
end
