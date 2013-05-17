class RepositoriesController < ApplicationController
	# GET /repositories
	# GET /repositories.json

  before_filter :set_section

  def set_section
    @section = 'repositories'
  end

	def index
		@repositories = Repository.find_all_by_owner_id(session[:owner_id])
    @user_read = @repositories
    @user = User.find(session[:user_id])
		@user_read = @user_read.delete_if { |x| !@user.has_permision?(x.id, 'read')  }
		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: @repositories }
		end
	end

	# GET /repositories/1
	# GET /repositories/1.json
	def show
		@repository = Repository.find_by_id_and_owner_id(params[:id], session[:owner_id])
		
    #buscamos el usuario que se corresponde con el de la session
    @user = User.find(session[:user_id])
    
    respond_to do |format|
      #comprobamos si tiene permisos de lectura si tiene lo dejamos pasar si no lo redirigimos al index
      if @user.has_permision?(@repository.id, "read")
        format.html # show.html.erb
        format.json { render json: @repository }
      else
        format.html { redirect_to(:action => 'index') }
        format.json { render json: @user }
      end
    end
  end

  # GET /repositories/new
  # GET /repositories/new.json
  def new
    @repository = Repository.new
    
    #buscamos el usuario que se corresponde con el de la session
    @user = User.find(session[:user_id])
		
    respond_to do |format|
      if @user.has_permision?(@repository.id, "read")
        format.html # new.html.erb
        format.json { render json: @repository }
      else
        format.html { redirect_to(:action => 'index') }
        format.json { render json: @user }
      end
    end
  end  


  # GET /repositories/1/edit
  def edit
    @repository = Repository.find_by_id_and_owner_id(params[:id], session[:owner_id])
    
    
    #buscamos el usuario que se corresponde con el de la session
    @user = User.find(session[:user_id])
    respond_to do |format|
      if @user.has_permision?(@repository.id, "read")
        format.html # new.html.erb
        format.json { render json: @repository }
      else
        format.html { redirect_to(:action => 'index') }
        format.json { render json: @user }
      end
    end
  end

  # POST /repositories
  # POST /repositories.json
  def create
    @repository = Repository.new(params[:repository])

    @repository.create_repo
    @repository.owner_id = session[:owner_id]
    respond_to do |format|
      if @repository.save
        format.html { redirect_to repositories_url, notice: 'Repository was successfully created.' }
        format.json { render json: @repository, status: :created, location: @repository }
      else
        format.html { render action: "new" }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /repositories/1
  # PUT /repositories/1.json
  def update
    @repository = Repository.find(params[:id])
		
    respond_to do |format|
      if @repository.update_attributes(params[:repository])
        format.html { redirect_to repositories_url, notice: 'Repository was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repositories/1
  # DELETE /repositories/1.json
  def destroy
    @repository = Repository.find_by_id_and_owner_id(params[:id], session[:owner_id])
  
    # Delete the repository folder
    %x[rm -Rf #{APP_CONFIG["repo_location"]}/#{@repository.slave_location}]
  
    @repository.destroy
  
    respond_to do |format|
      format.html { redirect_to repositories_url }
      format.json { head :no_content }
    end
  end

  # SVN Specific actions
  def show_log
    require 'xmlsimple'
  
    @repository = Repository.find_by_id(params[:id])
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
  
  end

  def browse
  
  end

  def sync
    @repository = Repository.find_by_id(params[:id])
  
    @repository.sync
    @repository.save
  
    respond_to do |format|
      format.html { redirect_to repositories_path }
    end
  end

end