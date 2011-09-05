class AddIsDefaultPoints < ActiveRecord::Migration
  def self.up
    add_column :points, :is_default, :boolean, :null => false, :default => false
  end

  def self.down
    add_column :points, :is_default
  end
end
