class IclPptpmtCourses < ActiveRecord::Base
  attr_accessible :course_id, :pmt_included, :ppt_included
  belongs_to :courses
end
