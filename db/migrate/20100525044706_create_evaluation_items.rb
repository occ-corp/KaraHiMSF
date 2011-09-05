class CreateEvaluationItems < ActiveRecord::Migration
  def self.up
    create_table :evaluation_items do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :evaluation_items
  end
end
