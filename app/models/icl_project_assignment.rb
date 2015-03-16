class IclProjectAssignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :icl_project
  attr_accessible :mark
end
