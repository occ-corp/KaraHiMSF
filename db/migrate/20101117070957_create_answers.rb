class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.boolean :answer, :null => false, :default => false
      t.integer :user_id
      t.integer :question_id

      t.timestamps
    end
  end

  def self.down
    drop_table :answers
  end
end
