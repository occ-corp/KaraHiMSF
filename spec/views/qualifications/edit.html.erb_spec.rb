require 'spec_helper'

describe "qualifications/edit.html.erb" do
  before(:each) do
    @qualification = assign(:qualification, stub_model(Qualification,
      :new_record? => false
    ))
  end

  it "renders the edit qualification form" do
    render

    rendered.should have_selector("form", :action => qualification_path(@qualification), :method => "post") do |form|
    end
  end
end
