class CreateWorkAssignments < ActiveRecord::Migration
  def self.up
    create_table :work_assignments do |t|
      t.string :type
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :work_assignments
  end
end
