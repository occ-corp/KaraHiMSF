require 'spec_helper'

describe "questions/edit.html.erb" do
  before(:each) do
    @question = assign(:question, stub_model(Question,
      :new_record? => false,
      :question => "MyText"
    ))
  end

  it "renders the edit question form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => question_path(@question), :method => "post" do
      assert_select "textarea#question_question", :name => "question[question]"
    end
  end
end
