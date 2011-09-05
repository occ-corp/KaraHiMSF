class ChangeEvaluationPublishedEmployees < ActiveRecord::Migration
  def self.up
    change_column :systems, :evaluation_published_employees, :boolean, :default => false
  end

  def self.down
    change_column :systems, :evaluation_published_employees, :boolean, :default => nil
  end
end
