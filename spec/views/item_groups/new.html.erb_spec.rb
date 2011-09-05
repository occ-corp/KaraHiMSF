require 'spec_helper'

describe "item_groups/new.html.erb" do
  before(:each) do
    assign(:item_group, stub_model(ItemGroup,
      :new_record? => true
    ))
  end

  it "renders new item_group form" do
    render

    rendered.should have_selector("form", :action => item_groups_path, :method => "post") do |form|
    end
  end
end
