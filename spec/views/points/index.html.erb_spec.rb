require 'spec_helper'

describe "points/index.html.erb" do
  before(:each) do
    assign(:points, [
      stub_model(Point),
      stub_model(Point)
    ])
  end

  it "renders a list of points" do
    render
  end
end
