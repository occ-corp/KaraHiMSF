require 'spec_helper'

describe "questions/show.html.erb" do
  before(:each) do
    @question = assign(:question, stub_model(Question,
      :question => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/MyText/)
  end
end
