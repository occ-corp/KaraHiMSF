require 'spec_helper'

describe "systems/index.html.erb" do
  before(:each) do
    assign(:systems, [
      stub_model(System),
      stub_model(System)
    ])
  end

  it "renders a list of systems" do
    render
  end
end
