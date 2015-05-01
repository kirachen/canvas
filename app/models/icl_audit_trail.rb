class IclAuditTrail < ActiveRecord::Base
  belongs_to :icl_project
  belongs_to :user
  attr_accessible :date, :entry
end
