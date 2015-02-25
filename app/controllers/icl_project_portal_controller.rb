class IclProjectPortalController < ApplicationController

    include SearchHelper
  def show
    @projects = IclProject.all
    p "Current user"
    p @current_user.id
  end

  def create
    #Create a new project when we get a 'CREATE' request
    @icl_project = IclProject.create(title:params[:title], description:params[:description], user_id:@current_user.id)
    #Current user is owner of the project
    @icl_project.user = @current_user
    if @icl_project.save()
        redirect_to action: "show"
        #TODO an else branch to error out
    end
  end

end
