require 'spec_helper'

describe "settings/edit.html.erb" do
  before(:each) do
    @setting = assign(:setting, stub_model(Setting,
      :new_record? => false
    ))
  end

  it "renders the edit setting form" do
    render

    rendered.should have_selector("form", :action => setting_path(@setting), :method => "post") do |form|
    end
  end
end
