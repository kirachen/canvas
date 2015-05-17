class IclCourseCls < ActiveRecord::Base
  attr_accessible :cls, :course_id
  belongs_to :courses
end
