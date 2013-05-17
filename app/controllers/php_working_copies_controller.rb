class PhpWorkingCopiesController < WorkingCopiesController

	def serv_restart
		@working_copy = WorkingCopy.find(params[:id])

		@working_copy.serv_restart

		respond_to do |format|
			format.html { redirect_to :controller => 'working_copies', :repository_id => params[:id]}
		end
	end

end