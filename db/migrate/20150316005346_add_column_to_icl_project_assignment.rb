class AddColumnToIclProjectAssignment < ActiveRecord::Migration
  tag:predeploy
  def change
    add_column :icl_project_assignments, :mark, :string, :defult => "N/A"
  end
end
