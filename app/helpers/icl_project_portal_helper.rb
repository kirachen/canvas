module IclProjectPortalHelper

    def get_thought_courses(user)
        enrollments = Enrollment.where(:user_id => user, :type=>"TeacherEnrollment")

        if enrollments.empty?
            return nil
        end
        course_ids_for_user = enrollments.map(&:course_id)
        courses_for_user = Course.find(course_ids_for_user)
    end

    def get_project_choice(user, project)
        choice = IclProjectChoice.where(:user_id => user, :icl_project_id => project).first()
        if choice == nil then
            return nil
        end
        choice.preference

    end
    
    def choose_project(params)
        
        preference = params[:preference]

        IclProjectChoice.where(:icl_project_id => params[:project_id], :user_id => @current_user).destroy_all()

        if preference != nil
    
            @choice = IclProjectChoice.new(preference:params[:preference])
            @choice.user = @current_user
            @choice.icl_project = IclProject.where(:id => params[:project_id]).first()
            @choice.save()

        end
    end

    def make_project_choice(user, project, preference)

        IclProjectChoice.where(:user_id => user, :preference => preference).destroy_all()
        if preference != nil then
            IclProjectChoice.create(:user_id => user, :icl_project_id  => project, :preference => preference)
        end

    end

    def is_main_admin(user)
        #Kind of a hack, gotta find a better way around it
        return (user.id==1)
    end

    def course_has_projects(course)
        IclProject.where(:course_id => course).any?
    end

    def get_course_projects(course)
        IclProject.where(:course_id => course)
    end

    def get_possible_choices(user, project_id)
        project = IclProject.where(:id => project_id).first()
        preferenes_chosen = IclProjectChoice.where(:user_id => user, :icl_project_id => IclProject.where(:course_id=>project.course)).map(&:preference)
        #Group project - 6 choices
        if project.category == 1 then
            return (1..6).step(1) - preferenes_chosen
        end

        #Individual Project - 3 choices
        if project.category == 2 then
            return (1..3).step(1) - preferenes_chosen
        end
    end

    def get_preference_for_project(user, project)
        IclProjectChoice.where(:user_id => user, :icl_project_id => project).first()

    end

    def get_choices_for_user(user, course)
        IclProjectChoice.where(:user_id => user, :icl_project_id => IclProject.where(:course_id=>course)).order(:preference)
    end

    def get_assigned_project(user, course)
        IclProjectAssignment.where(:user_id => user, :icl_project_id => IclProject.where(:course_id=>course)).first()
    end

    def is_teacher_in_course(user, course)
        course.teachers.exists?(:id => user)
    end

    def get_all_teachers
        Enrollment.where(:type=>"TeacherEnrollment").map{|e| [e.user.name, e.user.id]}.uniq
    end

    def is_second_marker(project_id, user_id)
        IclProjectAssignment.where(:icl_project_id => IclProject.find(project_id), :second_marker_id => User.find(user_id)).any?
    end

    def is_second_marker_in_course(course, user_id)
        IclProjectAssignment.where(:second_marker_id => user_id, :icl_project_id => IclProject.where(:course_id => course)).any?
    end

    def is_student_in_course(user, course)
        course.students.exists?(:id => user)
    end

    def get_project_supervised_by_teacher(user, course)
        ((IclProjectAssignment.where(:icl_project_id => IclProject.where(:user_id => user, :course_id => course))) + IclProjectAssignment.where(:second_marker_id => user, :icl_project_id => IclProject.where(:course_id => course)))
    end

    def get_project_by_id(project_id)
        IclProject.where(:id => project_id).first
    end

    def get_archived_projects
        IclProject.where(:archived => true)
    end

    def add_to_audit_trail(user_id, icl_project_id, entry)
        IclAuditTrail.create(:user_id => User.find(user_id),:icl_project_id => IclProject.find(icl_project_id), :entry => entry )
    end

    def get_audit_trail(user_id, icl_project_id)
        IclAuditTrail.where(:user_id => User.find(user_id), :icl_project_id => IclProject.find(icl_project_id))
    end

end
