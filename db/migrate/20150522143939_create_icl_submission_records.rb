class CreateIclSubmissionRecords < ActiveRecord::Migration
  tag :predeploy
  def change
    create_table :icl_submission_records do |t|
      t.integer :submission_id
      t.string :recorder_id

      t.timestamps
    end
  end
end
