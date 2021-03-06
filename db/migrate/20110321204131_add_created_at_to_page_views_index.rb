class AddCreatedAtToPageViewsIndex < ActiveRecord::Migration
  def self.up
    remove_index :page_views, :column => :account_id
    add_index :page_views, [ :account_id, :created_at ]
  end

  def self.down
    remove_index :page_views, :column => [ :account_id, :created_at ]
    add_index :page_views, :account_id
  end
end
