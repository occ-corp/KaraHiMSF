class AddEvaluationGroupIdEvaluationCategories < ActiveRecord::Migration
  def self.up
    add_column :evaluation_categories, :evaluation_group_id, :integer
  end

  def self.down
    remove_column :evaluation_categories, :evaluation_group_id
  end
end
