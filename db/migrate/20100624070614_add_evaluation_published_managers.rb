class AddEvaluationPublishedManagers < ActiveRecord::Migration
  def self.up
    add_column :systems, :evaluation_published_managers, :boolean
  end

  def self.down
    remove_column :systems, :evaluation_published_managers
  end
end
