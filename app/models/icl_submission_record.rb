class IclSubmissionRecord < ActiveRecord::Base
  attr_accessible :recorder_id, :submission_id
  belongs_to :submission
end
