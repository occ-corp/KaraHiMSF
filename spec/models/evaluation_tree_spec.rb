# -*- coding: utf-8 -*-
require 'spec_helper'

describe EvaluationTree do
  fixtures :all

  before :each do
    build_simple_evaluation_tree(EvaluationTree::TopDown)
    @json = @evaluation_tree_head.to_sexpr_recursively { |e| e.id }
  end

  it "respond to remove_empty_groups" do
    EvaluationTree.should respond_to(:remove_empty_groups)
  end

  describe "#to_sexpr_recursively" do
    # [EvaluationTree, []]
    #
    #  [
    #   head1, [
    #    [child0, []],
    #    [child1, []]
    #   ]
    #  ]

    it "should return the Array structure as the evaluation tree" do
      sexpr = @evaluation_tree_head.to_sexpr_recursively
      sexpr.should be_a_kind_of(Array)

      sexpr.length.should equal(2)

      sexpr.first.should equal(@evaluation_tree_head)

      sexpr.last.should be_a_kind_of(Array)
      sexpr.last.length.should equal(@evaluation_tree_head.children.length)

      sexpr.last.first.should be_a_kind_of(Array)
      sexpr.last.first.first.should == @evaluation_tree_child0
      sexpr.last.first.last.should be_a_kind_of(Array)
      sexpr.last.first.last.should be_empty

      sexpr.last.last.should be_a_kind_of(Array)
      sexpr.last.last.first.should == @evaluation_tree_child1
      sexpr.last.last.last.should be_a_kind_of(Array)
      sexpr.last.last.last.length.should equal(1)
      sexpr.last.last.last.first.should be_a_kind_of(Array)
      sexpr.last.last.last.first.first.should == @evaluation_tree_sub_child
      sexpr.last.last.last.first.last.should be_a_kind_of(Array)
      sexpr.last.last.last.first.last.should be_empty
    end

    it "should receive a block and include it's result in the return value" do
      sexpr = @evaluation_tree_head.to_sexpr_recursively {|t| t.to_s}
      sexpr.first.should == @evaluation_tree_head.to_s
    end
  end

  describe ".tranverse" do
    it "should raise RuntimeError because it is an abstract method" do
      lambda {
        EvaluationTree.tranverse(@json)
      }.should raise_error(RuntimeError)
    end
  end

  describe ".remove" do
    it "should call the removed callback" do
      mock_evaluation_tree = mock_model(EvaluationTree)
      callback = lambda { }
      callback.should_receive(:call).with(mock_evaluation_tree, nil)
      EvaluationTree.remove mock_evaluation_tree, :removed => callback
    end
  end

  describe ".to_csv" do
    before :each do
      @user = mock_model(User, {
                           :code => "",
                           :name => "",
                           :belongs => [],
                           :default_field => :login,
                           :login => "test",
                           :item_group => ItemGroup.first
                         })
      @evaluation_tree = mock_model(EvaluationTree, {
                                      :selected => true,
                                      :excluded => true,
                                      :user => @user,
                                      :level => 1,
                                    })
      @evaluation_trees = []
      @evaluation_trees.stub(:all) { [@evaluation_tree] }
      EvaluationTree.stub(:order_by_lft) { @evaluation_trees }
    end

    it "should call .order_by_lft" do
      options = { }
      @evaluation_trees.should_receive(:all).with(options) { [@evaluation_tree] }
      EvaluationTree.should_receive(:order_by_lft) { @evaluation_trees }
      EvaluationTree.to_csv(nil, false, options)
    end

    it "should include users.note when true received as with_note" do
      @evaluation_tree.should_receive(:note) { "" }
      csv_head = CSV.parse(EvaluationTree.to_csv(nil, true).toutf8).first
      csv_head.should include("備考")
    end

    it "should include users.note when false received as with_note" do
      @evaluation_tree.should_not_receive(:note)
      csv_head = CSV.parse(EvaluationTree.to_csv(nil, false).toutf8).first
      csv_head.should_not include("備考")
    end
  end
end
