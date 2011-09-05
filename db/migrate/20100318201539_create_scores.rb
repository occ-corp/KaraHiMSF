class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.integer :evaluation_id
      t.integer :item_belong_id
      t.integer :point_id

      t.timestamps
    end
  end

  def self.down
    drop_table :scores
  end
end
