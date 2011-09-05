require 'spec_helper'

describe "evaluation_orders/index.html.erb" do
  before(:each) do
    assign(:evaluation_orders, [
      stub_model(EvaluationOrder),
      stub_model(EvaluationOrder)
    ])
  end

  it "renders a list of evaluation_orders" do
    render
  end
end
