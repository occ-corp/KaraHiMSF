require 'spec_helper'

describe "evaluation_trees/edit.html.erb" do
  before(:each) do
    @evaluation_tree = assign(:evaluation_tree, stub_model(EvaluationTree,
      :new_record? => false,
      :type => "MyString",
      :user_id => 1,
      :head_id => 1,
      :parent_id => 1,
      :lft => 1,
      :rgt => 1
    ))
  end

  it "renders the edit evaluation_tree form" do
    render

    rendered.should have_selector("form", :action => evaluation_tree_path(@evaluation_tree), :method => "post") do |form|
      form.should have_selector("input#evaluation_tree_type", :name => "evaluation_tree[type]")
      form.should have_selector("input#evaluation_tree_user_id", :name => "evaluation_tree[user_id]")
      form.should have_selector("input#evaluation_tree_head_id", :name => "evaluation_tree[head_id]")
      form.should have_selector("input#evaluation_tree_parent_id", :name => "evaluation_tree[parent_id]")
      form.should have_selector("input#evaluation_tree_lft", :name => "evaluation_tree[lft]")
      form.should have_selector("input#evaluation_tree_rgt", :name => "evaluation_tree[rgt]")
    end
  end
end
