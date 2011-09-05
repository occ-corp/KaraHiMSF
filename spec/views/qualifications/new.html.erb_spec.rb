require 'spec_helper'

describe "qualifications/new.html.erb" do
  before(:each) do
    assign(:qualification, stub_model(Qualification,
      :new_record? => true
    ))
  end

  it "renders new qualification form" do
    render

    rendered.should have_selector("form", :action => qualifications_path, :method => "post") do |form|
    end
  end
end
