class CreateEvaluationCategoriesItems < ActiveRecord::Migration
  def self.up
    create_table :evaluation_categories_items do |t|
      t.integer :evaluation_category_id
      t.integer :item_id

      t.timestamps
    end
  end

  def self.down
    drop_table :evaluation_categories_items
  end
end
