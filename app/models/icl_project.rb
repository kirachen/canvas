class IclProject < ActiveRecord::Base
  belongs_to :user
  attr_accessible :description, :title, :category
  validates_presence_of :description, :title
end

