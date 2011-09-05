require 'spec_helper'

describe "sessions/edit.html.erb" do
  before(:each) do
    @session = assign(:session, stub_model(Session,
      :new_record? => false
    ))
  end

  it "renders the edit session form" do
    render

    rendered.should have_selector("form", :action => session_path(@session), :method => "post") do |form|
    end
  end
end
