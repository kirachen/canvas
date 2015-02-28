class IclProjectChoice < ActiveRecord::Base
  belongs_to :user
  belongs_to :icl_project
  attr_accessible :preference
  validates_presence_of :user, :icl_project, :preference
end
