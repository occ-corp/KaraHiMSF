require 'spec_helper'

describe EvaluationTree::Multifaceted do
  describe ".tranverse" do
    before :each do
      build_simple_evaluation_tree(EvaluationTree::Multifaceted)
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
        callback.should_receive(:call).with(@evaluation_tree_sub_child, nil)
        EvaluationTree::Multifaceted.tranverse(@json,
                                               {
                                                 :removed => callback
                                               })
      end

      it "should call the added callback" do
        callback = lambda { }
        callback.should_receive(:call).with(@evaluation_tree_sub_child, @evaluation_tree_head)
        EvaluationTree::Multifaceted.tranverse(@json,
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
        callback.should_receive(:call).with(@evaluation_tree_sub_child, nil)
        EvaluationTree::Multifaceted.tranverse(@json,
                                               {
                                                 :removed => callback
                                               })
      end
    end

    describe "when a node moved to under the group" do
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
        #     group
        #      \
        #       child1
        #       |
        #       child0
        #       |
        #       sub_child
        group = [nil, []]
        group.last.push @json.last.last.last.pop
        group.last.push @json.last.pop
        group.last.push @json.last.pop
        @json.last.push group

        @mock_evaluation_tree = mock_model(EvaluationTree::Multifaceted, {
                                             :name => nil,
                                             :parent => nil,
                                             "group?" => true,
                                           })
        EvaluationTree::Multifaceted.stub(:new) {
          @mock_evaluation_tree
        }
      end

      it "should call self.new to add new group" do
        EvaluationTree::Multifaceted.should_receive(:new) {
          @mock_evaluation_tree
        }
        EvaluationTree::Multifaceted.tranverse(@json)
      end

      it "should call the removed callback" do
        callback = lambda { }
        callback.should_receive(:call).with(@mock_evaluation_tree, nil)
        callback.should_receive(:call).with(@evaluation_tree_child0, nil)
        callback.should_receive(:call).with(@evaluation_tree_child1, nil)
        callback.should_receive(:call).with(@evaluation_tree_sub_child, nil)
        EvaluationTree::Multifaceted.tranverse(@json,
                                               {
                                                 :removed => callback
                                               })
      end

      it "should call the added callback" do
        callback = lambda { }
        callback.should_receive(:call).with(@mock_evaluation_tree, @evaluation_tree_head)
        EvaluationTree::Multifaceted.tranverse(@json,
                                               {
                                                 :added => callback
                                               })
      end

      it "should call the round_robin callback" do
        brothers_json = @json.last.last.last

        brother_ids = brothers_json.collect do |brother|
          brother.first
        end

        brothers = brother_ids.collect do |brother_id|
          EvaluationTree::Multifaceted.find(brother_id)
        end

        brothers.stub(:find_all_by_id).with(brother_ids) do
          brothers
        end

        EvaluationTree::Multifaceted.stub(:only_exactly_have_user) do
          brothers
        end

        callback = lambda { }
        callback.should_receive(:call).with(@evaluation_tree_sub_child,
                                            @mock_evaluation_tree,
                                            brothers,
                                            @evaluation_tree_head)
        callback.should_receive(:call).with(@evaluation_tree_child0,
                                            @mock_evaluation_tree,
                                            brothers,
                                            @evaluation_tree_head)
        callback.should_receive(:call).with(@evaluation_tree_child1,
                                            @mock_evaluation_tree,
                                            brothers,
                                            @evaluation_tree_head)
        EvaluationTree::Multifaceted.tranverse(@json, {:round_robin => callback})
      end
    end
  end
end
