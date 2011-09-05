class AddQuestionnaireExecutedSystems < ActiveRecord::Migration
  def self.up
    add_column :systems, :questionnaire_executed, :boolean, :default => false
  end

  def self.down
    remove_column :systems, :questionnaire_executed
  end
end
