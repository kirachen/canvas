class IclProject < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_many :icl_project_choice, dependent: :destroy
  attr_accessible :is_group, :description, :title, :category, :boolean
  validates_presence_of :description, :title
end

