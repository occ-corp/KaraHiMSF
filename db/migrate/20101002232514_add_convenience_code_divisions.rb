class AddConvenienceCodeDivisions < ActiveRecord::Migration
  def self.up
    add_column :divisions, :convenience_code, :string
  end

  def self.down
    remove_column :divisions, :convenience_code, :string
  end
end
