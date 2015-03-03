class CreateIclPptpmtCourses < ActiveRecord::Migration
  tag :predeploy
  def change
    create_table :icl_pptpmt_courses do |t|
      t.integer :course_id
      t.boolean :ppt_included
      t.boolean :pmt_included

      t.timestamps
    end
  end
end
