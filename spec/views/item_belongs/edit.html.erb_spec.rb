require 'spec_helper'

describe "item_belongs/edit.html.erb" do
  before(:each) do
    @item_belong = assign(:item_belong, stub_model(ItemBelong,
      :new_record? => false
    ))
  end

  it "renders the edit item_belong form" do
    render

    rendered.should have_selector("form", :action => item_belong_path(@item_belong), :method => "post") do |form|
    end
  end
end
