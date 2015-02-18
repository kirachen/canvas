class IclProjectPortalController < ApplicationController
  def show
  	@projects = IclProject.all
  	#Generate the view that displays all the projects
  end


end
