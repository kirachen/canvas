class IclPptpmtCourses < ActiveRecord::Base
  attr_accessible :course_id, :pmt_included, :ppt_included, :mmt_included, :jmt_included
  belongs_to :courses
end
