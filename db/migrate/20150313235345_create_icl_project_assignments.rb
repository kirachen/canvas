class CreateIclProjectAssignments < ActiveRecord::Migration
  tag:predeploy
  def change
    create_table :icl_project_assignments do |t|
      t.references :user
      t.references :icl_project

      t.timestamps
    end
    add_index :icl_project_assignments, :user_id
    add_index :icl_project_assignments, :icl_project_id
  end
end
