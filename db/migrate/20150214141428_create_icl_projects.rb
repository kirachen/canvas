class CreateIclProjects < ActiveRecord::Migration
  tag:predeploy
  def change
    create_table :icl_projects do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
