class AddIsGroupToIclProject < ActiveRecord::Migration
  tag :predeploy
  def change
    add_column :icl_projects, :isgroup, :string
  end
end
