require 'spec_helper'

describe "evaluation_trees/show.html.erb" do
  before(:each) do
    @evaluation_tree = assign(:evaluation_tree, stub_model(EvaluationTree,
      :type => "Type",
      :user_id => 1,
      :head_id => 1,
      :parent_id => 1,
      :lft => 1,
      :rgt => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should contain("Type".to_s)
    rendered.should contain(1.to_s)
    rendered.should contain(1.to_s)
    rendered.should contain(1.to_s)
    rendered.should contain(1.to_s)
    rendered.should contain(1.to_s)
  end
end
