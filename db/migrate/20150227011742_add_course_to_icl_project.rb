class AddCourseToIclProject < ActiveRecord::Migration
  tag:predeploy
  def change
    add_column :icl_projects, :course_id, :integer
  end
end
