require 'spec_helper'

describe "evaluation_categories/new.html.erb" do
  before(:each) do
    assign(:evaluation_category, stub_model(EvaluationCategory,
      :new_record? => true
    ))
  end

  it "renders new evaluation_category form" do
    render

    rendered.should have_selector("form", :action => evaluation_categories_path, :method => "post") do |form|
    end
  end
end
