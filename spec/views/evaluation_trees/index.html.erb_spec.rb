require 'spec_helper'

describe "evaluation_trees/index.html.erb" do
  before(:each) do
    assign(:evaluation_trees, [
      stub_model(EvaluationTree,
        :type => "Type",
        :user_id => 1,
        :head_id => 1,
        :parent_id => 1,
        :lft => 1,
        :rgt => 1
      ),
      stub_model(EvaluationTree,
        :type => "Type",
        :user_id => 1,
        :head_id => 1,
        :parent_id => 1,
        :lft => 1,
        :rgt => 1
      )
    ])
  end

  it "renders a list of evaluation_trees" do
    render
    rendered.should have_selector("tr>td", :content => "Type".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
  end
end
