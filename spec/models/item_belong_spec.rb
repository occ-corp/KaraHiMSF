require 'spec_helper'

describe ItemBelong do
  before :each do
    ItemBelong.delete_all
    Item.delete_all
    ItemGroup.delete_all

    @item = Item.create :evaluation_category => EvaluationCategory.create,
    :evaluation_item => EvaluationItem.create,
    :seq => 1

    @item2 = Item.create :evaluation_category => EvaluationCategory.create,
    :evaluation_item => EvaluationItem.create,
    :seq => 2

    @item_group = ItemGroup.create
  end

  it "validates uniqueness of item_id field" do
    item_belong = ItemBelong.new :item_group_id => @item_group.id, :item_id => @item.id, :seq => 1
    item_belong.valid?.should be_true
    item_belong.save.should be_true

    item_belong = ItemBelong.new :item_group_id => @item_group.id, :item_id => @item.id, :seq => 2
    item_belong.valid?.should be_false
    item_belong.errors.should include(:item_id)
  end

  it "validates uniqueness of seq field" do
    item_belong = ItemBelong.new :item_group_id => @item_group.id, :item_id => @item.id, :seq => 1
    item_belong.valid?.should be_true
    item_belong.save.should be_true

    item_belong = ItemBelong.new :item_group_id => @item_group.id, :item_id => @item2.id, :seq => 1
    item_belong.valid?.should be_false
    item_belong.errors.should include(:seq)
  end
end
