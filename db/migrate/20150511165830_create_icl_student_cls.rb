class CreateIclStudentCls < ActiveRecord::Migration
  tag :predeploy
  def change
    create_table :icl_student_cls do |t|
      t.integer :user_id
      t.string :cls

      t.timestamps
    end
  end
end
