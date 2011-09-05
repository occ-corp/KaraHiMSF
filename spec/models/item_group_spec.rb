require 'spec_helper'

describe ItemGroup do
  before :each do
    @item_group = ItemGroup.create :name => "test"
  end

  it "should validates uniqueness of name on create" do
    item_group = ItemGroup.new :name => @item_group.name
    item_group.valid?.should be_false
    item_group.errors.should include(:name)
  end

  it "should not validates uniqueness of name on update" do
    @item_group.update_attribute(:name, @item_group.name).should be_true
  end
end
