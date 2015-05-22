class IclPaperSubmissionController < ApplicationController
  helper_method :get_expected_number_submissions, :get_course_title, :get_faos, :get_actual_number_submissions

  def show
    @assignments = Assignment.active.where("due_at>=? AND submission_types=?", Time.now, "on_paper").order(:context_id)
  end

  def scan
    barcode = params[:barcode]
    data = barcode.split("exe")
    if data.size == 2
      student_login = data[0]
      user_id = Pseudonym.active.where("unique_id=?", student_login).first.user_id
      exe = data[1].split("grp")
      assignment_id = exe[0]
      group_id = exe[1]
      if group_id != "0"
        members = GroupMembership.active.where(:group_id => group_id)
        members.each do |member|
          submission = Submission.new
          submission.workflow_state = "submitted"
          submission.group_id = group_id
          submission.user_id = member.user_id
          submission.assignment_id = assignment_id
          submission.save
          record = IclSubmissionRecord.new
          record.submission_id = submission.id
          record.recorder_id = @current_user.all_active_pseudonyms.first.unique_id
          record.save
        end
      else
        submission = Submission.new
        submission.workflow_state = "submitted"
        submission.user_id = user_id
        submission.assignment_id = assignment_id
        submission.save
        record = IclSubmissionRecord.new
        record.submission_id = submission.id
        record.recorder_id = @current_user.all_active_pseudonyms.first.unique_id
        record.save
      end
    end
    redirect_to action: "show"
  end

  def get_expected_number_submissions(assignment)
    if is_group_assignment? assignment
      return Group.active.where("group_category_id=?", assignment.group_category_id).size
    else
      course_id = assignment.context_id
      return Enrollment.active.where("course_id=? AND type=?", course_id, "StudentEnrollment").size
    end
  end

  def get_actual_number_submissions(assignment)
    if is_group_assignment? assignment
      groups = Set.new
      submissions = Submission.where("assignment_id=?", assignment.id)
      submissions.each do |submission|
        groups.add submission.group_id
      end
      return groups.size
    else
      course_id = assignment.context_id
      return Submission.where("assignment_id=?", assignment.id).size
    end
  end

  def get_course_title(assignment)
    course_id = assignment.context_id
    course = Course.find(course_id)
    return course.name + " " + course.course_code
  end

  def get_faos(assignment)
    faos = []
    course_id = assignment.context_id
    enrolls = Enrollment.active.where("course_id = ? AND type=?", course_id, "TeacherEnrollment")
    enrolls.each do |e|
        user = User.find(e.user_id)
        faos.append(user.name)
    end
    return faos
  end

  def is_group_assignment?(assignment)
    return assignment.group_category_id.present?
  end

end
