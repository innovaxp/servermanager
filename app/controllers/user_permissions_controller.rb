class UserPermissionsController < ApplicationController
  # GET /user_permissions
  # GET /user_permissions.json
  def index
    @repositories = Repository.find(:all, :conditions => ['owner_id=?', session[:user_id]])

    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_permissions }
    end
  end

  # GET /user_permissions/1
  # GET /user_permissions/1.json
  def show
    @user_permission = UserPermission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_permission }
    end
  end

  # GET /user_permissions/new
  # GET /user_permissions/new.json
  def new
    @user_permission = UserPermission.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_permission }
    end
  end

  # GET /user_permissions/1/edit
  def edit
    @user_permission = UserPermission.find(params[:id])
  end

  # POST /user_permissions
  # POST /user_permissions.json
  def create
    
    @user_permission = UserPermission.new(params[:user_permission])

    respond_to do |format|
      if @user_permission.save
        format.html { redirect_to @user_permission, notice: 'User permission was successfully created.' }
        format.json { render json: @user_permission, status: :created, location: @user_permission }
      else
        format.html { render action: "new" }
        format.json { render json: @user_permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_permissions/1
  # PUT /user_permissions/1.json
  def update
    @user_permission = UserPermission.find(params[:id])

    respond_to do |format|
      if @user_permission.update_attributes(params[:user_permission])
        format.html { redirect_to @user_permission, notice: 'User permission was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_permissions/1
  # DELETE /user_permissions/1.json
  def destroy
    @user_permission = UserPermission.find(params[:id])
    @user_permission.destroy

    respond_to do |format|
      format.html { redirect_to user_permissions_url }
      format.json { head :no_content }
    end
  end

  # Recibe el repository_id como parámetro y muestra una vista
  # donde podemos editar los permisos de los usuarios
  def edit_permissions_on_repository
    @repository = Repository.find(params[:repository_id])
    # Users con owner_id == mi id
    @users = User.find(:all , :conditions =>['owner_id=? AND id!=?', session[:owner_id], @repository.owner_id])
    
    
    #raise @users.to_yaml
    respond_to do |format|
      format.html
      format.json { head :no_content }
    end
  end

  def update_permissions_on_repository
    @repository = Repository.find(params[:repository_id])
    #raise params.to_yaml
 
    #buscamos el mismo user que tiene 
    @user_find = UserPermission.find(:all,:conditions=>["repository_id=?",@repository.owner_id])
    @user_find.each do |us|
      us.destroy
    end
    
    if params[:permission] && params[:permission].kind_of?(Hash)

      params[:permission].each do |user_id, value|
        us_perm = UserPermission.new
        us_perm.user_id = user_id
        us_perm.repository_id = @repository.id

        value.each do |type, val|

          if type=='read' && (val == 1 || val == '1')
            us_perm.read_permission = true
          elsif type=='write' && (val == 1 || val == '1')
            us_perm.write_permission = true
          end
        end
        us_perm.save
      end
    end
    respond_to do |format|
        format.html { redirect_to(:action => "index", :repository_id => @repository.id, :notice => 'User permission was successfully updated.' ) }
        format.json { head :no_content }
      end
  end
end
