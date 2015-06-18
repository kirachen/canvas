class IclAttendanceController < ApplicationController

  def attendance
    get_context
    add_crumb(t('#crumbs.attendance', "Attendance"), named_context_url(@context, :context_details_url))
    if @context.user_is_student?(@current_user)
      redirect_to action: "student_attendance"
      return
    end
    @attendances = IclAttendance.where(:course_id => @context.id).order(:tutoring_date)
    @students = @context.students_visible_to(@current_user).order_by_sortable_name
  end

  def student_attendance
    get_context
    add_crumb(t('#crumbs.attendance', "Attendance"), named_context_url(@context, :context_details_url))
    if !@context.user_is_student?(@current_user)
      redirect_to action: "attendance"
      return
    end
    @attendances = IclAttendance.where(:course_id => @context.id).order(:tutoring_date)
    @students = @context.students_visible_to(@current_user).order_by_sortable_name
  end

  def new_entry
    get_context
    if params[:new_entry_date] == "Select date"
      redirect_to action: "attendance"
      return
    end
    if @context.name == "PPT" || @context.name == "PMT" || @context.name == "MMT" || @context.name == "JMT"
      new_entry_date = Date.strptime(params[:new_entry_date], "%m/%d/%Y")
      if !IclAttendance.where(:course_id => params[:course_id], :tutoring_date => new_entry_date).exists?
        attendance = IclAttendance.new
        attendance.course_id = params[:course_id]
        attendance.last_updated_by = @current_user.all_active_pseudonyms.first.unique_id
        attendance.tutoring_date = new_entry_date
        attendance.present_student = Array.new
        attendance.absent_student = Array.new
        @students = @context.students_visible_to(@current_user).order_by_sortable_name
        @students.each do |student|
          id = student.all_active_pseudonyms.first.unique_id
          if params[id] == "1"
            attendance.present_student.push(id)
          else
            attendance.absent_student.push(id)
          end
        end
        attendance.save
      end
    end
    respond_to do |format|
      format.html do
        redirect_to action: "attendance"
      end
    end
  end
  
  def remove_entry
    id = params[:attendance]
    attendance = IclAttendance.find(id)
    attendance.destroy
    respond_to do |format|
      format.html do
        redirect_to action: "attendance"
      end
    end
  end


  def update_attendance_entry
    get_context
    attendance_id = params[:attendance]
    attendance = IclAttendance.find(attendance_id)
    attendance.last_updated_by = @current_user.all_active_pseudonyms.first.unique_id
    attendance.present_student = Array.new
    attendance.absent_student = Array.new
    @students = @context.students_visible_to(@current_user).order_by_sortable_name
    @students.each do |student|
      id = student.all_active_pseudonyms.first.unique_id
      if params[id] == "1"
        attendance.present_student.push(id)
      else
        attendance.absent_student.push(id)
      end
    end
    attendance.save
    respond_to do |format|
      format.html do
        redirect_to action: "attendance"
      end
    end
  end
end
