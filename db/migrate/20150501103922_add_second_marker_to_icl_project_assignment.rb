class AddSecondMarkerToIclProjectAssignment < ActiveRecord::Migration
  tag :predeploy
  def change
    add_column :icl_project_assignments, :second_marker_id, :integer
  end
end
