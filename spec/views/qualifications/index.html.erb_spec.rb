require 'spec_helper'

describe "qualifications/index.html.erb" do
  before(:each) do
    assign(:qualifications, [
      stub_model(Qualification),
      stub_model(Qualification)
    ])
  end

  it "renders a list of qualifications" do
    render
  end
end
