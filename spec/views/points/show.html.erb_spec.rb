require 'spec_helper'

describe "points/show.html.erb" do
  before(:each) do
    @point = assign(:point, stub_model(Point))
  end

  it "renders attributes in <p>" do
    render
  end
end
