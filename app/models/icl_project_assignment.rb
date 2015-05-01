class IclProjectAssignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :icl_project
  belongs_to :second_marker, :class_name => 'User'
  attr_accessible :mark
end
