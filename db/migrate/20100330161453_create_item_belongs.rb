class CreateItemBelongs < ActiveRecord::Migration
  def self.up
    create_table :item_belongs do |t|
      t.integer :item_id
      t.integer :item_group_id
      t.float :weight

      t.timestamps
    end
  end

  def self.down
    drop_table :item_belongs
  end
end
