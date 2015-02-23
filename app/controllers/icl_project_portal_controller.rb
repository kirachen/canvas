class IclProjectPortalController < ApplicationController

    include SearchHelper
  def show
    @projects = IclProject.all
    #Generate the view that displays all the projects + differentiate between students and teachers
    p "LOOK HERE"
    p context
    p @current_user
  end

  def create
    p "Here baby!"
    p params
    @icl_project = IclProject.create(title:params[:title], description:params[:description])
    if @icl_project.save()
        redirect_to action: "show"
    end
  end

end
