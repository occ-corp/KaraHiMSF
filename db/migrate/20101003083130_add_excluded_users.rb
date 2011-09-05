class AddExcludedUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :excluded, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :excluded
  end
end
