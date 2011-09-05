require 'spec_helper'

describe "item_belongs/show.html.erb" do
  before(:each) do
    @item_belong = assign(:item_belong, stub_model(ItemBelong))
  end

  it "renders attributes in <p>" do
    render
  end
end
