require 'spec_helper'

describe "sessions/new.html.erb" do
  before(:each) do
    assign(:session, stub_model(Session,
      :new_record? => true
    ))
  end

  it "renders new session form" do
    render

    rendered.should have_selector("form", :action => sessions_path, :method => "post") do |form|
    end
  end
end
