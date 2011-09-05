class CreateItemsQualifications < ActiveRecord::Migration
  def self.up
    create_table :items_qualifications do |t|
      t.integer :item_id
      t.integer :qualification_id
      t.float :weight

      t.timestamps
    end
  end

  def self.down
    drop_table :items_qualifications
  end
end
