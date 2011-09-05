require 'spec_helper'

describe "evaluation_categories/edit.html.erb" do
  before(:each) do
    @evaluation_category = assign(:evaluation_category, stub_model(EvaluationCategory,
      :new_record? => false
    ))
  end

  it "renders the edit evaluation_category form" do
    render

    rendered.should have_selector("form", :action => evaluation_category_path(@evaluation_category), :method => "post") do |form|
    end
  end
end
