class CreateEvaluationOrders < ActiveRecord::Migration
  def self.up
    create_table :evaluation_orders do |t|
      t.string :type
      t.string :name
      t.float :weight

      t.timestamps
    end
  end

  def self.down
    drop_table :evaluation_orders
  end
end
