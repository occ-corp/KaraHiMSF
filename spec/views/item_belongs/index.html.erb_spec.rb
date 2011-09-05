require 'spec_helper'

describe "item_belongs/index.html.erb" do
  before(:each) do
    assign(:item_belongs, [
      stub_model(ItemBelong),
      stub_model(ItemBelong)
    ])
  end

  it "renders a list of item_belongs" do
    render
  end
end
