require 'spec_helper'

describe "systems/new.html.erb" do
  before(:each) do
    assign(:system, stub_model(System,
      :new_record? => true
    ))
  end

  it "renders new system form" do
    render

    rendered.should have_selector("form", :action => systems_path, :method => "post") do |form|
    end
  end
end
