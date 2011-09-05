require 'spec_helper'

describe "qualifications/show.html.erb" do
  before(:each) do
    @qualification = assign(:qualification, stub_model(Qualification))
  end

  it "renders attributes in <p>" do
    render
  end
end
