class ChangeColumnTypeOfAttedance < ActiveRecord::Migration
  tag :predeploy
  def up
    change_column :icl_attendances, :present_student, :string, array:true, default: []
    change_column :icl_attendances, :absent_student, :string, array:true, default: []
  end

  def down
  end
end
