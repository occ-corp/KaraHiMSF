class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :evaluation_category_id
      t.integer :evaluation_item_id

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
