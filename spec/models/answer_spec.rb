require 'spec_helper'

describe Answer do
  before :each do
    Answer.delete_all
    @answer = Answer.create! :user_id => 1, :question_id => 1
  end

  it "validates question_id is unique on user_id scope" do
    answer = Answer.new :question_id => @answer.user_id, :user_id => @answer.question_id
    answer.should_not be_valid
    answer.errors.should include(:question_id)
  end
end
