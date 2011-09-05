require 'spec_helper'

describe "scores/index.html.erb" do
  before(:each) do
    assign(:scores, [
      stub_model(Score),
      stub_model(Score)
    ])
  end

  it "renders a list of scores" do
    render
  end
end
