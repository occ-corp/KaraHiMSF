require 'spec_helper'

describe "evaluation_categories/index.html.erb" do
  before(:each) do
    assign(:evaluation_categories, [
      stub_model(EvaluationCategory),
      stub_model(EvaluationCategory)
    ])
  end

  it "renders a list of evaluation_categories" do
    render
  end
end
