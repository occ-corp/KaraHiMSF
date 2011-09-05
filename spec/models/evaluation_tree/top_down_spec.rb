require 'spec_helper'

describe EvaluationTree::TopDown do
  describe ".tranverse" do
    before :each do
      build_simple_evaluation_tree(EvaluationTree::TopDown)
      @json = @evaluation_tree_head.to_sexpr_recursively { |e| e.id }
    end

    describe "when a node was moved to child of another parent" do
      before :each do
        # Initial tree:
        #
        #   head
        #    \
        #     child0
        #     |
        #     child1
        #      \
        #       sub_child
        #
        # Modified tree:
        #
        #   head
        #    \
        #     child0
        #     |
        #     child1
        #     |
        #     sub_child
        @json.last.push @json.last.last.last.pop
      end

      it "should call the removed callback" do
        callback = lambda { }
        callback.should_receive(:call).with(@evaluation_tree_sub_child, @evaluation_tree_child1)
        EvaluationTree::TopDown.tranverse(@json,
                                          {
                                            :removed => callback
                                          })
      end

      it "should call the added callback" do
        callback = lambda { }
        callback.should_receive(:call).with(@evaluation_tree_sub_child, @evaluation_tree_head)
        EvaluationTree::TopDown.tranverse(@json,
                                          {
                                            :added => callback
                                          })
      end
    end

    describe "when a node was moved to root" do
      before :each do
        # Initial tree:
        #
        #   head
        #    \
        #     child0
        #     |
        #     child1
        #      \
        #       sub_child
        #
        # Modified tree:
        #
        #  |\
        #  | head
        #  |  \
        #  |   child0
        #  |   |
        #  |   child1
        #   \
        #    sub_child
        @json = @json.last.last.last.pop
      end

      it "should call the removed callback" do
        callback = lambda { }
        callback.should_receive(:call).with(@evaluation_tree_sub_child, @evaluation_tree_child1)
        EvaluationTree::TopDown.tranverse(@json,
                                          {
                                            :removed => callback
                                          })
      end
    end
  end
end
