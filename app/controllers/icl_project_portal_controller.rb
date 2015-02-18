class IclProjectPortalController < ApplicationController
  def show
  	@projects = IclProject.all
  	#Generate the view that displays all the projects + differentiate between students and teachers
  	
  end


end
