class AddCategoryToIclProject < ActiveRecord::Migration
  tag:predeploy
  def change
    add_column :icl_projects, :category, :integer
  end
end
