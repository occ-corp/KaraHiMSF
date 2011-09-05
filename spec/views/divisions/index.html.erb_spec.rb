require 'spec_helper'

describe "divisions/index.html.erb" do
  before(:each) do
    assign(:divisions, [
      stub_model(Division),
      stub_model(Division)
    ])
  end

  it "renders a list of divisions" do
    render
  end
end
