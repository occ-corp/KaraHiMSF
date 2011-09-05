require 'spec_helper'

describe "questions/new.html.erb" do
  before(:each) do
    assign(:question, stub_model(Question,
      :question => "MyText"
    ).as_new_record)
  end

  it "renders new question form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => questions_path, :method => "post" do
      assert_select "textarea#question_question", :name => "question[question]"
    end
  end
end
