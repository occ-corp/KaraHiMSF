class AddFiscalCodeDivisions < ActiveRecord::Migration
  def self.up
    add_column :divisions, :fiscal_code, :string
  end

  def self.down
    remove_column :divisions, :fiscal_code
  end
end
