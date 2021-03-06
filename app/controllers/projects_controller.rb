class ProjectsController < ApplicationController

	# TODO kelly -- how should we get beyond authentication for query?
	# should we do a custom authentication in 'query' or should we add something to 'signed_in?' in sessions_helper.rb?
	
	before_filter :authenticate, :except => [:query, :createjson]
	before_filter :authenticate_salt, :only => [:query, :createjson]
	
	respond_to :html, :json

	def index
		render 'pages/login'	
	end
	

	def show
  	  @project = Project.find(params[:id])


	end

	# kelly -- adding this to get all projects for a user
	def query	
		@projects = Project.find_all_by_user_id(params[:user_id])
		
		respond_with(@projects)
    end


	def new
		@project = Project.new
	end

	def create
		@language = Language.find_by_name(params[:project][:language])
		
		@language_id = -1
		if @language
			@language_id = @language.id
		else
			flash[:error] = "Could not find language.  Are languages loaded in the DB? "
		end
		
		@project = current_user.projects.build(:name => params[:project][:name], 
			:description => params[:project][:description],	
			:activity => params[:project][:activity],
			:language_id => @language_id,
			:user_id => current_user.id
		)
		
		if @project.save
			flash[:success] = "Successfully created "+@project.name
			redirect_to @project
		end
	end
	
	def createjson
		@language = Language.find_by_name(params[:project][:language])
		
		@language_id = -1
		if @language
			@language_id = @language.id
		end
		
		@user = User.find_by_id(params[:user_id])
		
		@local_id = params[:project][:local_id]
		
		@id = params[:project][:id]
		@project = Project.find_by_id(@id)
		if @project
		
			@local_updated = Time.parse(params[:project][:local_updated]).utc
			Logger.new(STDOUT).info('createjson -- project exists')
			# this has to be converted to a string...
			Logger.new(STDOUT).info('createjson -- remote date : ' + @project.updated_at.to_s)
			Logger.new(STDOUT).info('createjson -- local date : ' + @local_updated.to_s)
			
			if @local_updated > @project.updated_at.beginning_of_day
				Logger.new(STDOUT).info('createjson -- Local project is newer, updating the Heroku project...')
				
				# updating the project to be saved down below...
				@project.name = params[:project][:name]
				@project.description = params[:project][:description]
				@project.activity = params[:project][:activity]
				@project.local_id = @local_id
				@project.project_date = params[:project][:project_date]
				
			else
				Logger.new(STDOUT).info('createjson -- Heroku project is newer')
			end
			
		else
			@project = @user.projects.build(:name => params[:project][:name], 
				:description => params[:project][:description],	
				:activity => params[:project][:activity],
				:language_id => @language_id,
				:user_id => params[:user_id],
				:local_id => @local_id,
				:project_date => params[:project][:project_date]
			)
		end
		
		if @project.save
			respond_with do |format|                                                
				format.html do                                                      
					redirect_to @project 
				end
                                                                        
				#for json                                                           
				format.json {respond_with @project}                                     
			end                                                                                                                                       
		end
		
	end



	private

    def authenticate
      deny_access unless signed_in?
    end

	def authenticate_salt
      deny_access unless signed_in_salt?
    end

end
