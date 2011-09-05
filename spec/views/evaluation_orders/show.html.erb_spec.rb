require 'spec_helper'

describe "evaluation_orders/show.html.erb" do
  before(:each) do
    @evaluation_order = assign(:evaluation_order, stub_model(EvaluationOrder))
  end

  it "renders attributes in <p>" do
    render
  end
end
