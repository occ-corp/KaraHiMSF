require 'spec_helper'

describe "settings/new.html.erb" do
  before(:each) do
    assign(:setting, stub_model(Setting,
      :new_record? => true
    ))
  end

  it "renders new setting form" do
    render

    rendered.should have_selector("form", :action => settings_path, :method => "post") do |form|
    end
  end
end
