require 'spec_helper'

describe "items/new.html.erb" do
  before(:each) do
    assign(:item, stub_model(Item,
      :new_record? => true
    ))
  end

  it "renders new item form" do
    render

    rendered.should have_selector("form", :action => items_path, :method => "post") do |form|
    end
  end
end
