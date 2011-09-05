require 'spec_helper'

describe "evaluation_items/show.html.erb" do
  before(:each) do
    @evaluation_item = assign(:evaluation_item, stub_model(EvaluationItem))
  end

  it "renders attributes in <p>" do
    render
  end
end
