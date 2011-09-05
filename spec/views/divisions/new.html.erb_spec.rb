require 'spec_helper'

describe "divisions/new.html.erb" do
  before(:each) do
    assign(:division, stub_model(Division,
      :new_record? => true
    ))
  end

  it "renders new division form" do
    render

    rendered.should have_selector("form", :action => divisions_path, :method => "post") do |form|
    end
  end
end
