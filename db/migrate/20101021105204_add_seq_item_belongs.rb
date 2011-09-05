class AddSeqItemBelongs < ActiveRecord::Migration
  def self.up
    add_column :item_belongs, :seq, :integer
  end

  def self.down
    remove_column :item_belongs, :seq
  end
end
