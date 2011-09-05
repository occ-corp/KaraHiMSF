class AddEvaluationClosedSystems < ActiveRecord::Migration
  def self.up
    add_column :systems, :evaluation_closed, :boolean
  end

  def self.down
    remove_column :systems, :evaluation_closed
  end
end
