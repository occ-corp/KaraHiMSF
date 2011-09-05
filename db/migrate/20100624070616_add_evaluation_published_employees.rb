class AddEvaluationPublishedEmployees < ActiveRecord::Migration
  def self.up
    add_column :systems, :evaluation_published_employees, :boolean
  end

  def self.down
    remove_column :systems, :evaluation_published_employees
  end
end
