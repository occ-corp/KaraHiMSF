class ChangeEvaluationPublishedManagers < ActiveRecord::Migration
  def self.up
    change_column :systems, :evaluation_published_managers, :boolean, :default => false
  end

  def self.down
    change_column :systems, :evaluation_published_managers, :boolean, :default => nil
  end
end
