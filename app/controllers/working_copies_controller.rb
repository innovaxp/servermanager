class WorkingCopiesController < ApplicationController
	# GET /working_copies
	# GET /working_copies.json
	def index
    if(params[:repository_id] && !params[:repository_id].nil?)
      @repository = Repository.find_by_id_and_owner_id(params[:repository_id], session[:owner_id])
      @working_copies = WorkingCopy.find_all_by_repository_id_and_owner_id(params[:repository_id], session[:owner_id])
    elsif(params[:remote_server_id] && !params[:remote_server_id].nil?)
      @remote_server = RemoteServer.find_by_id_and_owner_id(params[:remote_server_id], session[:owner_id])
      @working_copies = WorkingCopy.find_all_by_remote_server_id_and_owner_id(params[:remote_server_id], session[:owner_id])
    end
    
    #buscamos el usuario que se corresponde con el de la session
    @user = User.find(session[:user_id])
    
		respond_to do |format|
      #comprobamos si tiene permisos de lectura si tiene lo dejamos pasar si no lo redirigimos al index
      if @user.has_permision?(@repository.id, "read")
        format.html # index.html.erb
        format.json { render json: @working_copies }
      else
        format.html { redirect_to(:controller => "repositories", :action => 'index') }
        format.json { render json: @user }
      end
		end
	end

	# GET /working_copies/1
	# GET /working_copies/1.json
	def show
		@working_copy = WorkingCopy.find_by_id_and_owner_id(params[:id], session[:owner_id])
		@repository = Repository.find_by_id_and_owner_id(params[:repository_id], session[:owner_id])
    
    #buscamos el usuario que se corresponde con el de la session
    @user = User.find(session[:user_id])
    
		respond_to do |format|
      if @user.has_permision?(@repository.id, "read")
        format.html # show.html.erb
        format.json { render json: @working_copy }
      else
        format.html { redirect_to(:controller => "repositories", :action => 'index') }
        format.json { render json: @user }
      end
		end
	end

	# GET /working_copies/new
	# GET /working_copies/new.json
	def new
		@working_copy = WorkingCopy.new
		@repository = Repository.find_by_id(params[:repository_id])
		@working_copy.repository_id = @repository.id
		@types = WorkingCopy.types
    
		respond_to do |format|
			format.html # new.html.erb
			format.json { render json: @working_copy }
		end
	end

	# GET /working_copies/1/edit
	def edit
		@working_copy = WorkingCopy.find(params[:id])
		@repository = Repository.find_by_id(params[:repository_id])
		@types = WorkingCopy.types
    @editing = true
    
    #buscamos el usuario que se corresponde con el de la session
    @user = User.find(session[:user_id])
    
		respond_to do |format|
      if @user.has_permision?(@repository.id, "read")
        format.html # new.html.erb
        format.json { render json: @working_copy }
      else
        format.html { redirect_to(:controller => "repositories", :action => 'index') }
        format.json { render json: @user }
      end
    end
  end

  # POST /working_copies
  # POST /working_copies.json
  def create

    type = params[:working_copy][:type]

    params[:working_copy].delete(:type)

    @working_copy = eval(type).new(params[:working_copy])
    @repository = Repository.find_by_id(params[:working_copy][:repository_id])
    @types = WorkingCopy.types
    @working_copy.lock = false
    @working_copy.owner_id = session[:owner_id]
    respond_to do |format|
      if @working_copy.save
        format.html { redirect_to working_copies_url(:repository_id => @repository.id), notice: 'Working copy was successfully created.' }
        format.json { render json: @working_copy, status: :created, location: @working_copy }
      else
        format.html { render action: "new" }
        format.json { render json: @working_copy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /working_copies/1
  # PUT /working_copies/1.json
  def update
    @working_copy = WorkingCopy.find(params[:id])
    @repository = Repository.find_by_id(params[:repository_id])
    @types = WorkingCopy.types
    
    respond_to do |format|
      if @working_copy.update_attributes(params[:working_copy])
        format.html { redirect_to working_copies_url(:repository_id => @working_copy.repository.id), notice: _('Updated successfully')}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @working_copy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /working_copies/1
  # DELETE /working_copies/1.json
  def destroy
    @working_copy = WorkingCopy.find_by_id_and_owner_id(params[:id], session[:owner_id])
    @repository = @working_copy.repository
    @working_copy.destroy
		

    respond_to do |format|
      format.html { redirect_to working_copies_url(:repository_id => @repository.id) }
      format.json { head :no_content }
    end
  end

  # SVN Specific actions
  def checkout
    @working_copy = WorkingCopy.find(params[:id])

    @working_copy.repository.sync
    @working_copy.repository.save

    @working_copy.checkout
    @working_copy.save

    respond_to do |format|
      if params[:from] && params[:from] == 'repo'
        format.html { redirect_to working_copies_url(:repository_id => @working_copy.repository.id), notice: _('Checkout was successfull')}
      else
        format.html { redirect_to working_copies_url(:remote_server_id => @working_copy.remote_server.id), notice: _('Checkout was successfull')}
      end
    end
  end

  def update_wc
    @working_copy = WorkingCopy.find(params[:id])

    @working_copy.repository.sync
    @working_copy.repository.save

    response = @working_copy.update_wc
    @working_copy.save

    #raise response[:error_message].to_s

    respond_to do |format|
      if response && response.class == Hash && response[:error_message]
        flash[:object_id] = response[:object].id
        flash[:error_message] = response[:error_message]
      else
        flash[:notice] = _('Update was successfull')
      end
      
      if params[:from] && params[:from] == 'repo'
        format.html { redirect_to working_copies_url(:repository_id => @working_copy.repository.id) }
      else
        format.html { redirect_to working_copies_url(:remote_server_id => @working_copy.remote_server.id) }
      end
      
    end
  end

  def rollback_wc
    @working_copy = WorkingCopy.find_by_id_and_owner_id(params[:id], session[:owner_id])

    @working_copy.repository.sync
    @working_copy.repository.save

    @working_copy.rollback_wc(params[:revision])
    @working_copy.save

    respond_to do |format|
      if params[:from] && params[:from] == 'repo'
        format.html { redirect_to working_copies_url(:repository_id => @working_copy.repository.id), notice: _('Rollback was successfull')}
      else
        format.html { redirect_to working_copies_url(:remote_server_id => @working_copy.remote_server.id), notice: _('Rollback was successfull')}
      end
    end
  end

  def check_status
    @working_copy = WorkingCopy.find_by_id_and_owner_id(params[:id], session[:owner_id])
		
    @working_copy.check_svn_status
		
    @working_copy.save

    respond_to do |format|
      if params[:from] && params[:from] == 'repo'
        format.html { redirect_to working_copies_url(:repository_id => @working_copy.repository.id), notice: _('Status checked')}
      else
        format.html { redirect_to working_copies_url(:remote_server_id => @working_copy.remote_server.id), notice: _('Status checked')}
      end
    end
  end

  def update_to_r
    @working_copy = WorkingCopy.find_by_id_and_owner_id(params[:id], session[:owner_id])

    require 'xmlsimple'

    @repository = Repository.find_by_id(@working_copy.repository_id)
    @repository.sync
    @repository.save

    xml_log = %x[svn log --xml --verbose file://#{@repository.full_path} 2>&1]
    @log_info = XmlSimple.xml_in(xml_log, { 'ForceArray' => false })['logentry']

    if !@log_info
      @log_info = Array.new
    end

    xml_info = %x[svn info --xml file://#{@repository.full_path} 2>&1]
    @repo_info = XmlSimple.xml_in(xml_info, { 'ForceArray' => false })["entry"]

    if !@repo_info
      @repo_info = Array.new
    end

    respond_to do |format|
      format.html
    end
  end
  #@author: Carlos
  #@params: :working_copy_id OBLIGATORIO MANDARLO SIEMPRE
  #@params: :password Necesario sólo para desbloquear el Working Copy
  #llamada ejemplo: localhost:3000/working_copies/wc_change_lock_status?working_copy_id=1&password=**pardi**
  #
  def wc_change_lock_status
    if params[:working_copy_id] && !params[:working_copy_id].nil?
      @working_copy = WorkingCopy.find_by_id_and_owner_id(params[:working_copy_id],session[:owner_id])
      if @working_copy && !@working_copy.nil?
        
        if @working_copy.lock == false
          if @working_copy.owner_id == session[:owner_id]
            @working_copy.lock = true
          end
        else
          if(params[:password] && !params[:password].nil? && @working_copy.owner_id == session[:owner_id])
            user = User.find_by_id(session[:user_id])
            pass = Base64.decode64(params[:password])
            if user && !user.nil? && user.authenticate(pass)
              #raise "cambiado"
              @working_copy.lock = false
            else
              error = true
            end
              
          end
        end
      end
    end

    respond_to do |format|
      if @working_copy && @working_copy.save && !error
        format.html { redirect_to working_copies_url(:repository_id => @working_copy.repository_id), notice: (@working_copy.lock ? 'Working copy was successfully locked.' :  'Working copy was successfully unlocked.') }
        format.json { render json: @working_copy, status: :created, location: @working_copy }
      else
        format.html { redirect_to repositories_url, notice: 'There was a problem changing lock status. Please try again.' }
        format.json { render json: { "message" => _('Incorrect password') }, status: :unprocessable_entity }
      end
    end
  end

  #PARDI#
  #Método que devuelve a la llamada Ajax el contenido del log del server
  def view_log

    @working_copy=WorkingCopy.find_by_id_and_owner_id(params[:working_copy_id], session[:owner_id])
    if params[:lines].to_s && params[:lines].to_s != ''
      lines = params[:lines].to_s
    else
      lines = '200'
    end
    if @working_copy
      log = @working_copy.get_log(lines)
    end
    if !@working_copy || !log
      log = _('No log found')
    end    
    respond_to do |format|
      #format.html # view_log.html.erb
      format.iframe {render self.to_iframe}
      format.json { render json: {"message" => log} }
    end
  end

  ## PARDI
  ## Método  de prueba, ahora lo hacemos a través de view_log
  def get_log_file
    text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."

    text = text + text + text

    respond_to do |format|
      format.html
      format.json { render json: {"file_text" => text} }
    end


  end


  def to_iframe
    @nobuttons = true
    return :action => params[:action]+".html", :layout => "no_layout"
  end


end
