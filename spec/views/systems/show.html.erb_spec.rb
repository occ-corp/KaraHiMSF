require 'spec_helper'

describe "systems/show.html.erb" do
  before(:each) do
    @system = assign(:system, stub_model(System))
  end

  it "renders attributes in <p>" do
    render
  end
end
