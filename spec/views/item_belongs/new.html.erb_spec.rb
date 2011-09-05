require 'spec_helper'

describe "item_belongs/new.html.erb" do
  before(:each) do
    assign(:item_belong, stub_model(ItemBelong,
      :new_record? => true
    ))
  end

  it "renders new item_belong form" do
    render

    rendered.should have_selector("form", :action => item_belongs_path, :method => "post") do |form|
    end
  end
end
