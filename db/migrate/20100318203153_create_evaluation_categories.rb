class CreateEvaluationCategories < ActiveRecord::Migration
  def self.up
    create_table :evaluation_categories do |t|
      t.string :type
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :evaluation_categories
  end
end
