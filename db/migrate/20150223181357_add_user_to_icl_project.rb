class AddUserToIclProject < ActiveRecord::Migration
  tag:predeploy
  def change
    add_column :icl_projects, :user_id, :integer
  end
end
