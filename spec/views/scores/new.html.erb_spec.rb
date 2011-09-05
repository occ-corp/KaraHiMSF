require 'spec_helper'

describe "scores/new.html.erb" do
  before(:each) do
    assign(:score, stub_model(Score,
      :new_record? => true
    ))
  end

  it "renders new score form" do
    render

    rendered.should have_selector("form", :action => scores_path, :method => "post") do |form|
    end
  end
end
