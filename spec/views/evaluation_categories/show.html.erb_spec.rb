require 'spec_helper'

describe "evaluation_categories/show.html.erb" do
  before(:each) do
    @evaluation_category = assign(:evaluation_category, stub_model(EvaluationCategory))
  end

  it "renders attributes in <p>" do
    render
  end
end
