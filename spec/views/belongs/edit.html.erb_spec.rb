require 'spec_helper'

describe "belongs/edit.html.erb" do
  before(:each) do
    @belong = assign(:belong, stub_model(Belong,
      :new_record? => false
    ))
  end

  it "renders the edit belong form" do
    render

    rendered.should have_selector("form", :action => belong_path(@belong), :method => "post") do |form|
    end
  end
end
