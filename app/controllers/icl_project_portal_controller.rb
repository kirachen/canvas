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

    if @icl_project.save()
        redirect_to action: "show"
    end
  end

end
