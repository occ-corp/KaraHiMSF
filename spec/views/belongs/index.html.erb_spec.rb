require 'spec_helper'

describe "belongs/index.html.erb" do
  before(:each) do
    assign(:belongs, [
      stub_model(Belong),
      stub_model(Belong)
    ])
  end

  it "renders a list of belongs" do
    render
  end
end
