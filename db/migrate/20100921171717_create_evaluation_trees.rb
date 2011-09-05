class CreateEvaluationTrees < ActiveRecord::Migration
  def self.up
    create_table :evaluation_trees do |t|
      t.string :type
      t.string :name            # for unit test
      t.integer :user_id
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.boolean :selected, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :evaluation_trees
  end
end
