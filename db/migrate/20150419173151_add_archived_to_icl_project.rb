class AddArchivedToIclProject < ActiveRecord::Migration
  tag:predeploy
  def change
    add_column :icl_projects, :archived, :boolean
  end
end
