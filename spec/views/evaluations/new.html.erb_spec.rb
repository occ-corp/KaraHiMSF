require 'spec_helper'

describe "evaluations/new.html.erb" do
  before(:each) do
    assign(:evaluation, stub_model(Evaluation,
      :new_record? => true
    ))
  end

  it "renders new evaluation form" do
    render

    rendered.should have_selector("form", :action => evaluations_path, :method => "post") do |form|
    end
  end
end
