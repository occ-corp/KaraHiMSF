require 'spec_helper'

describe "points/edit.html.erb" do
  before(:each) do
    @point = assign(:point, stub_model(Point,
      :new_record? => false
    ))
  end

  it "renders the edit point form" do
    render

    rendered.should have_selector("form", :action => point_path(@point), :method => "post") do |form|
    end
  end
end
