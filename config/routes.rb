Servermanager::Application.routes.draw do
  
  match 'user_permissions/permissions_on_repository/:repository_id' => 'user_permissions#edit_permissions_on_repository'
  match 'user_permissions/update_permissions_on_repository/:repository_id' => 'user_permissions#update_permissions_on_repository'

  resources :user_permissions

  match 'manage_alerts' => 'alerts#edit', :as => :manage_alerts
  
  resources :alerts

	resources :upload_services

  match 'backup_configurations/get_user_databases' => 'backup_configurations#get_user_databases'

	resources :backup_configurations

  match 'backups/list_historical_backup' => 'backups#list_historical_backup'

  match 'backups/restore_backup' => 'backups#restore_backup'
  
  match 'backups/upload_finished_callback' => 'backups#upload_finished_callback'

	resources :backups

	match 'backup_configurations/run_backup/:id' => 'backup_configurations#run_backup'

	match 'backups/retry_upload/:id' => 'backups#retry_upload'

	match 'backups/retry_backup/:id' => 'backups#retry_backup'
  


	match 'rails_working_copies/:id/:action' => 'rails_working_copies#:action'
	match 'php_working_copies/:id/:action' => 'php_working_copies#:action'

	resources :php_working_copies
	resources :rails_working_copies

	match 'working_copies/:repository_id' => 'working_copies#index', :repository_id => /\d+/
	match 'working_copies/wc_change_lock_status' => 'working_copies#wc_change_lock_status'
	match 'working_copies/view_log/:working_copy_id' => 'working_copies#view_log'
	match 'working_copies/get_log_file' => 'working_copies#get_log_file'


	resources :working_copies

	resources :repositories

	match 'working_copies(/:id)/:action' => 'working_copies#:action'
	match 'repositories(/:id)/:action' => 'repositories#:action'

  resources :root_remote_servers
  resources :account_remote_servers
  #account
  match 'remote_servers/:root_remote_server_id/create_account' => 'remote_servers#create_account'
  match 'remote_servers/:root_remote_server_id/new_account' => 'remote_servers#new_account'
  #cron
  match 'remote_servers/:remote_server_id/create_cron' => 'remote_servers#create_cron'
  match 'remote_servers/:remote_server_id/new_cron' => 'remote_servers#new_cron'
  match 'remote_servers/:remote_server_id/delete_cron' => 'remote_servers#delete_cron'
  match 'remote_servers/:account_remote_servers_id/show_crons' => 'remote_servers#show_crons'
  match 'remote_servers/:account_remote_servers_id/toggle_cron_activation' => 'remote_servers#toggle_cron_activation'
  #account_remote_server
  match 'remote_servers/edit_account/:id' => 'remote_servers#edit_account'
  match 'remote_servers/update_account/:id' => 'remote_servers#update_account'
  #email_account
  match 'remote_servers/:account_remote_servers_id/new_email_account' => 'remote_servers#new_email_account'
  match 'remote_servers/:account_remote_servers_id/create_email_account' => 'remote_servers#create_email_account'
  match 'remote_servers/:account_remote_servers_id/edit_email_account' => 'remote_servers#edit_email_account'
  match 'remote_servers/:account_remote_servers_id/update_email_account' => 'remote_servers#update_email_account'
  match 'remote_servers/:account_remote_servers_id/show_emails_account' => 'remote_servers#show_emails_account'
  match 'remote_servers/:account_remote_servers_id/delete_email_account' => 'remote_servers#delete_email_account'
  #email_forward
  match 'remote_servers/:account_remote_servers_id/new_email_forward' => 'remote_servers#new_email_forward'
  match 'remote_servers/:account_remote_servers_id/create_email_forward' => 'remote_servers#create_email_forward'
  match 'remote_servers/:account_remote_servers_id/delete_email_forward' => 'remote_servers#delete_email_forward'
  match 'remote_servers/:account_remote_servers_id/show_emails_forwarders' => 'remote_servers#show_emails_forwarders'
  #backups
  #ruta  'ej: remote_servers/10/new => (controlador#action)
  match 'remote_servers/:remote_server_id/new_backup' => 'backup_configurations#new'
  match 'remote_servers/:remote_server_id/edit_file_backup' => 'backup_configurations#edit_file_backup'
  match 'remote_servers/:remote_server_id/edit_database_backup' => 'backup_configurations#edit_database_backup'
  match 'remote_servers/:remote_server_id/index' => 'backup_configurations#index'
  match 'remote_servers/:remote_server_id/new_file_backup' => 'backup_configurations#new_file_backup'
  match 'remote_servers/:remote_server_id/new_database_backup' => 'backup_configurations#new_database_backup'
  match 'remote_servers/:remote_server_id/toggle_file_backup_activation' => 'backup_configurations#toggle_file_backup_activation'
  match 'remote_servers/:remote_server_id/toggle_database_backup_activation' => 'backup_configurations#toggle_database_backup_activation'
  #catch_all
  match 'remote_servers/:account_remote_servers_id/new_catch_all' => 'remote_servers#new_catch_all'
  match 'remote_servers/:account_remote_servers_id/create_catch_all' => 'remote_servers#create_catch_all'
  match 'remote_servers/:account_remote_servers_id/delete_catch_all' => 'remote_servers#delete_catch_all'

  resources :remote_servers

  #dns_managements
  match 'remote_servers/:remote_server_id/new_dns' => 'remote_servers#new_dns'
  match 'remote_servers/:remote_server_id/edit_dns' => 'remote_servers#edit_dns'
  match 'remote_servers/:remote_server_id/create_dns' => 'remote_servers#create_dns'
  match 'remote_servers/:remote_server_id/update_dns' => 'remote_servers#update_dns'
  match 'remote_servers/:remote_server_id/delete_dns' => 'remote_servers#delete_dns'
  match 'remote_servers/:remote_server_id/show_dns_managements' => 'remote_servers#show_dns_managements'

	root :to => 'application#index'

	match 'users/change_active' => 'users#change_active'
	resources :users

	controller :sessions do
		get 'login' => :new
		post 'login' => :create
		get 'logout' => :destroy
	end

	match 'file_search/:action' => 'file_search#:action'
	match 'subversion/:action' => 'subversion#:action'

	# The priority is based upon order of creation:
	# first created -> highest priority.

	# Sample of regular route:
	#   match 'products/:id' => 'catalog#view'
	# Keep in mind you can assign values other than :controller and :action

	# Sample of named route:
	#   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
	# This route can be invoked with purchase_url(:id => product.id)

	# Sample resource route (maps HTTP verbs to controller actions automatically):
	#   resources :products

	# Sample resource route with options:
	#   resources :products do
	#     member do
	#       get 'short'
	#       post 'toggle'
	#     end
	#
	#     collection do
	#       get 'sold'
	#     end
	#   end

	# Sample resource route with sub-resources:
	#   resources :products do
	#     resources :comments, :sales
	#     resource :seller
	#   end

	# Sample resource route with more complex sub-resources
	#   resources :products do
	#     resources :comments
	#     resources :sales do
	#       get 'recent', :on => :collection
	#     end
	#   end

	# Sample resource route within a namespace:
	#   namespace :admin do
	#     # Directs /admin/products/* to Admin::ProductsController
	#     # (app/controllers/admin/products_controller.rb)
	#     resources :products
	#   end

	# You can have the root of your site routed with "root"
	# just remember to delete public/index.html.
	# root :to => 'welcome#index'

	# See how all your routes lay out with "rake routes"

	# This is a legacy wild controller route that's not recommended for RESTful applications.
	# Note: This route will make all actions in every controller accessible via GET requests.
	# match ':controller(/:action(/:id))(.:format)'
end
