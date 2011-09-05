require 'spec_helper'

describe "item_groups/edit.html.erb" do
  before(:each) do
    @item_group = assign(:item_group, stub_model(ItemGroup,
      :new_record? => false
    ))
  end

  it "renders the edit item_group form" do
    render

    rendered.should have_selector("form", :action => item_group_path(@item_group), :method => "post") do |form|
    end
  end
end
