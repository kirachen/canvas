class CreateIclAssignmentMaps < ActiveRecord::Migration
  tag :predeploy
  def change
    create_table :icl_assignment_maps do |t|
      t.integer :assignment_id
      t.string :small_group_assignment_ids

      t.timestamps
    end
  end
end
