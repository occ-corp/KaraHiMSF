require 'spec_helper'

describe "evaluation_trees/new.html.erb" do
  before(:each) do
    assign(:evaluation_tree, stub_model(EvaluationTree,
      :new_record? => true,
      :type => "MyString",
      :user_id => 1,
      :head_id => 1,
      :parent_id => 1,
      :lft => 1,
      :rgt => 1
    ))
  end

  it "renders new evaluation_tree form" do
    render

    rendered.should have_selector("form", :action => evaluation_trees_path, :method => "post") do |form|
      form.should have_selector("input#evaluation_tree_type", :name => "evaluation_tree[type]")
      form.should have_selector("input#evaluation_tree_user_id", :name => "evaluation_tree[user_id]")
      form.should have_selector("input#evaluation_tree_head_id", :name => "evaluation_tree[head_id]")
      form.should have_selector("input#evaluation_tree_parent_id", :name => "evaluation_tree[parent_id]")
      form.should have_selector("input#evaluation_tree_lft", :name => "evaluation_tree[lft]")
      form.should have_selector("input#evaluation_tree_rgt", :name => "evaluation_tree[rgt]")
    end
  end
end
