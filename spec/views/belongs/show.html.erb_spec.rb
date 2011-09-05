require 'spec_helper'

describe "belongs/show.html.erb" do
  before(:each) do
    @belong = assign(:belong, stub_model(Belong))
  end

  it "renders attributes in <p>" do
    render
  end
end
