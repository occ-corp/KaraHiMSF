class AddNoteItemBelongs < ActiveRecord::Migration
  def self.up
    add_column :item_belongs, :note, :text
  end

  def self.down
    remove_column :item_belongs, :note
  end
end
