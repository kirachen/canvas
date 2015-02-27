class AddCourseToIclProject < ActiveRecord::Migration
  def change
    add_column :icl_projects, :course_id, :integer
  end
end
