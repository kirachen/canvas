class AddMmtjmtToIclPptpmtCourses < ActiveRecord::Migration
  tag :predeploy

  def change
    add_column :icl_pptpmt_courses, :mmt_included, :boolean
    add_column :icl_pptpmt_courses, :jmt_included, :boolean
  end
end
