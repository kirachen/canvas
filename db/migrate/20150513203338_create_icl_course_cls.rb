class CreateIclCourseCls < ActiveRecord::Migration
  tag :predeploy
  def change
    create_table :icl_course_cls do |t|
      t.integer :course_id
      t.string :cls

      t.timestamps
    end
  end
end
