class CreateIclAuditTrails < ActiveRecord::Migration
  tag :predeploy
  def change
    create_table :icl_audit_trails do |t|
      t.references :icl_project
      t.references :user
      t.timestamp :date
      t.string :entry

      t.timestamps
    end
    add_index :icl_audit_trails, :icl_project_id
    add_index :icl_audit_trails, :user_id
  end
end
