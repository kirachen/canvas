class IclStudentCls < ActiveRecord::Base
  attr_accessible :cls, :user_id
  belongs_to :users
end
