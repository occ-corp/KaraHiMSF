require 'spec_helper'

describe "divisions/edit.html.erb" do
  before(:each) do
    @division = assign(:division, stub_model(Division,
      :new_record? => false
    ))
  end

  it "renders the edit division form" do
    render

    rendered.should have_selector("form", :action => division_path(@division), :method => "post") do |form|
    end
  end
end
