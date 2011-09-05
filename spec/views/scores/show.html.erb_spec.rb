require 'spec_helper'

describe "scores/show.html.erb" do
  before(:each) do
    @score = assign(:score, stub_model(Score))
  end

  it "renders attributes in <p>" do
    render
  end
end
