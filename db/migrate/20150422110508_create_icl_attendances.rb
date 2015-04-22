class CreateIclAttendances < ActiveRecord::Migration
  tag :predeploy
  def change
    create_table :icl_attendances do |t|
      t.integer :course_id
      t.string :last_updated_by
      t.date :tutoring_date
      t.string :present_student
      t.string :absent_student

      t.timestamps
    end
  end
end
