class AddWorkAssignmentIdBelongs < ActiveRecord::Migration
  def self.up
    add_column :belongs, :work_assignment_id, :integer
  end

  def self.down
    remove_column :belongs, :work_assignment_id
  end
end
