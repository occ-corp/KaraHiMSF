require 'spec_helper'

describe "divisions/show.html.erb" do
  before(:each) do
    @division = assign(:division, stub_model(Division))
  end

  it "renders attributes in <p>" do
    render
  end
end
