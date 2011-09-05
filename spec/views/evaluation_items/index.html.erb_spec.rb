require 'spec_helper'

describe "evaluation_items/index.html.erb" do
  before(:each) do
    assign(:evaluation_items, [
      stub_model(EvaluationItem),
      stub_model(EvaluationItem)
    ])
  end

  it "renders a list of evaluation_items" do
    render
  end
end
