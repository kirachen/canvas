class IclProjectPortalController < ApplicationController

    include IclProjectPortalHelper


  def show
    @projects = IclProject.all
    @courses = Course.all - IclIndividualProject.all.collect{|e| e.course}
    @is_admin = is_main_admin(@current_user)
  end
  
  def course_projects
    @courses = Course.all - IclIndividualProject.all.collect{|e| e.course}

  end

  def individual_projects
    @individual_projects = IclIndividualProject.all.collect{|e| e.course}
  end

  def create
    @thought_courses = get_thought_courses(@current_user)
    @is_teacher = @thought_courses != nil
    #Create a new project when we get a 'CREATE' request
    #@icl_project = IclProject.new(title:params[:title], description:params[:description], category:params[:category])
    #Current user is owner of the project
    #p "Parameters"
    #p params
    #@icl_project.user = @current_user
    #@icl_project.course = Course.where(:id => params[:course]).first()
    #@icl_project.save()
    #redirect_to action: "show"
        #TODO an else branch to error out
  end

  def create_project
    @icl_project = IclProject.new(title:params[:title], description:params[:description], category:params[:category])
    #Current user is owner of the project
    p "Parameters"
    p params
    @icl_project.user = @current_user
    @icl_project.course = Course.where(:id => params[:course]).first()
    @icl_project.save()
    redirect_to action: "create"
  end

  def choose_indiv
    choose_project(params)
    redirect_to action: "individual_projects"
  end

  def choose_projects
    choose_project(params)
    redirect_to action: "course_projects"
  end
  def choose
    p "Parameters"
    p params
    preference = params[:preference]

    IclProjectChoice.where(:icl_project_id => params[:project_id], :user_id => @current_user).destroy_all()

    if preference != nil
    
      @choice = IclProjectChoice.new(preference:params[:preference])
      @choice.user = @current_user
      @choice.icl_project = IclProject.where(:id => params[:project_id]).first()
      @choice.save()

    end
    redirect_to action: "show"
  end

  def choose_individual_project_course
    course = Course.where(:id => params[:course]).first()

    if IclIndividualProject.first() == nil then
      invidual_project = IclIndividualProject.new()
      invidual_project.course = course
      invidual_project.save()
    else
      invidual_project = IclIndividualProject.first()
      invidual_project.course = course
      invidual_project.save()
    end
    redirect_to action: "show"
  end

  def assign_projects
    
  end
end
