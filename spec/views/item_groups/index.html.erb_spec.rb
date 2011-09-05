require 'spec_helper'

describe "item_groups/index.html.erb" do
  before(:each) do
    assign(:item_groups, [
      stub_model(ItemGroup),
      stub_model(ItemGroup)
    ])
  end

  it "renders a list of item_groups" do
    render
  end
end
