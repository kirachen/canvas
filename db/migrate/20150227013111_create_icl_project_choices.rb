class CreateIclProjectChoices < ActiveRecord::Migration
  tag:predeploy
  def change
    create_table :icl_project_choices do |t|
      t.references :user
      t.references :icl_project
      t.integer :preference

      t.timestamps
    end
    add_index :icl_project_choices, :user_id
    add_index :icl_project_choices, :icl_project_id
  end
end
