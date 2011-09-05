class CreatePoints < ActiveRecord::Migration
  def self.up
    create_table :points do |t|
      t.string :name
      t.string :abbrev
      t.float :point
      t.integer :seq

      t.timestamps
    end
  end

  def self.down
    drop_table :points
  end
end
