require 'spec_helper'

describe "evaluations/edit.html.erb" do
  before(:each) do
    @evaluation = assign(:evaluation, stub_model(Evaluation,
      :new_record? => false
    ))
  end

  it "renders the edit evaluation form" do
    render

    rendered.should have_selector("form", :action => evaluation_path(@evaluation), :method => "post") do |form|
    end
  end
end
