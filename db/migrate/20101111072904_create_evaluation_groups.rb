class CreateEvaluationGroups < ActiveRecord::Migration
  def self.up
    create_table :evaluation_groups do |t|
      t.string :type
      t.string :name
      t.float :weight

      t.timestamps
    end
  end

  def self.down
    drop_table :evaluation_groups
  end
end
