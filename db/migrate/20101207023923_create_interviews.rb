class CreateInterviews < ActiveRecord::Migration
  def self.up
    create_table :interviews do |t|
      t.integer :evaluation_id
      t.datetime :done_at

      t.timestamps
    end
  end

  def self.down
    drop_table :interviews
  end
end
