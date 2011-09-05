require 'spec_helper'

describe "points/new.html.erb" do
  before(:each) do
    assign(:point, stub_model(Point,
      :new_record? => true
    ))
  end

  it "renders new point form" do
    render

    rendered.should have_selector("form", :action => points_path, :method => "post") do |form|
    end
  end
end
