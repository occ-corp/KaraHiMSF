class CreateBelongs < ActiveRecord::Migration
  def self.up
    create_table :belongs do |t|
      t.integer :user_id
      t.integer :division_id
      t.integer :job_title_id
      t.boolean :primary_flag   # primary は PostgreSQL 予約語のため

      t.timestamps
    end
  end

  def self.down
    drop_table :belongs
  end
end
