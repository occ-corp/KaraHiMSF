require 'spec_helper'

describe "belongs/new.html.erb" do
  before(:each) do
    assign(:belong, stub_model(Belong,
      :new_record? => true
    ))
  end

  it "renders new belong form" do
    render

    rendered.should have_selector("form", :action => belongs_path, :method => "post") do |form|
    end
  end
end
