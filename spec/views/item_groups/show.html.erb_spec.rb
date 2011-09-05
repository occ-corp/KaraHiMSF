require 'spec_helper'

describe "item_groups/show.html.erb" do
  before(:each) do
    @item_group = assign(:item_group, stub_model(ItemGroup))
  end

  it "renders attributes in <p>" do
    render
  end
end
