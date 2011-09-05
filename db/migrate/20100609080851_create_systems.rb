class CreateSystems < ActiveRecord::Migration
  def self.up
    create_table :systems do |t|
      t.datetime :implementation_term_start_at
      t.datetime :implementation_term_finish_at
      t.datetime :evaluation_term_start_at
      t.datetime :evaluation_term_finish_at

      t.timestamps
    end
  end

  def self.down
    drop_table :systems
  end
end
