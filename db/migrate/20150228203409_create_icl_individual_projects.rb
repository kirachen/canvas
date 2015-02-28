class CreateIclIndividualProjects < ActiveRecord::Migration
  tag:predeploy
  def change
    create_table :icl_individual_projects do |t|
      t.references :course

      t.timestamps
    end
    add_index :icl_individual_projects, :course_id
  end
end
