class ChangeEvaluationClosedSystems < ActiveRecord::Migration
  def self.up
    change_column :systems, :evaluation_closed, :boolean, :default => false
  end

  def self.down
    change_column :systems, :evaluation_closed, :boolean, :default => nil
  end
end
