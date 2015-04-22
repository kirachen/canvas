class IclAttendance < ActiveRecord::Base
  attr_accessible :absent_student, :course_id, :last_updated_by, :present_student, :tutoring_date
  belongs_to :courses
end
