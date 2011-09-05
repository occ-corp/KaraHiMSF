require 'spec_helper'

describe "items/edit.html.erb" do
  before(:each) do
    @item = assign(:item, stub_model(Item,
      :new_record? => false
    ))
  end

  it "renders the edit item form" do
    render

    rendered.should have_selector("form", :action => item_path(@item), :method => "post") do |form|
    end
  end
end
