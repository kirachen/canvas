class AddCategoryToIclProject < ActiveRecord::Migration
  def change
    add_column :icl_projects, :category, :integer
  end
end
