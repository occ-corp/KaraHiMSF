require 'spec_helper'

describe "scores/edit.html.erb" do
  before(:each) do
    @score = assign(:score, stub_model(Score,
      :new_record? => false
    ))
  end

  it "renders the edit score form" do
    render

    rendered.should have_selector("form", :action => score_path(@score), :method => "post") do |form|
    end
  end
end
