require 'spec_helper'

describe "systems/edit.html.erb" do
  before(:each) do
    @system = assign(:system, stub_model(System,
      :new_record? => false
    ))
  end

  it "renders the edit system form" do
    render

    rendered.should have_selector("form", :action => system_path(@system), :method => "post") do |form|
    end
  end
end
