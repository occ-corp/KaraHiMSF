# -*- coding: utf-8 -*-

require 'spec_helper'

describe User do
  fixtures :all

  describe "scope" do
    before :each do
      Evaluation.delete_all
      @user = User.first
      @object_users = User.all
      @object_users.delete @user
    end

    describe "under_evaluation_tree" do
      before :each do
        @root = EvaluationTree::TopDown.find_by_user_id(User.find_by_login("ueunten"))
        @child = EvaluationTree::TopDown.find_by_user_id(User.find_by_login("ueno"))
        @sub_child = EvaluationTree::TopDown.find_by_user_id(User.find_by_login("ueyonabaru"))
        @another = EvaluationTree::TopDown.find_by_user_id(User.find_by_login("urasaki"))
        @sub_child.move_to_child_of(@child)
        @child.move_to_child_of(@root)
      end

      it "should collect users under the tree" do
        User.under_evaluation_tree(@root).all.should include(@child.user, @sub_child.user)
      end

      it "should not include itself" do
        User.under_evaluation_tree(@root).all.should_not include(@root.user)
      end

      it "should return empty array when no users under the tree" do
        User.under_evaluation_tree(@another).all.should be_empty
      end
    end

    describe "only_unevaluated" do
      before :each do
        @evaluation_order = EvaluationOrder::TopDown.first
        @object_users.each do |object_user|
          Evaluation.create!(:user => @user,
                             :object_user => object_user,
                             :evaluation_order => @evaluation_order)
        end
        @evaluation_category = EvaluationCategory::TopDown.first
      end

      it "responds to paginate" do
        @user.object_users.only_unevaluated(@user, @evaluation_category).should respond_to(:paginate)
      end

      it "should all unevaluated object users" do
        object_users = @user.object_users.only_unevaluated(@user, @evaluation_category)
        object_users.length.should eq(@object_users.length)
        @object_users.each { |user| object_users.should include(user) }
      end

      it "should not take evaluated object users" do
        object_user = @object_users.first
        item_belongs = object_user.item_group.item_belongs.scope_by_evaluation_category_and_order_by_evaluation_item(@evaluation_category)
        evaluation = object_user.passive_evaluations.first
        point = Point.first
        item_belongs.each do |item_belong|
          Score.create! :evaluation => evaluation, :item_belong => item_belong, :point => point
        end
        @user.object_users.only_unevaluated(@user, @evaluation_category).should_not include(object_user)
      end
    end

    describe "scope_by_evaluation_order_type" do
      it "should find all object users of the top-down evaluation" do
        evaluation_order = EvaluationOrder::TopDown.first
        @object_users.each do |object_user|
          Evaluation.create!(:user => @user,
                             :object_user => object_user,
                             :evaluation_order => evaluation_order)
        end
        object_users = @user.object_users.scope_by_evaluation_order_type(EvaluationOrder::TopDown)
        @object_users.each do |object_user|
          object_users.should include(object_user)
        end
      end

      it "should find all object users of the multifaceted evaluation" do
        evaluation_order = EvaluationOrder::Multifaceted.first
        @object_users.each do |object_user|
          Evaluation.create!(:user => @user,
                             :object_user => object_user,
                             :evaluation_order => evaluation_order)
        end
        object_users = @user.object_users.scope_by_evaluation_order_type(EvaluationOrder::Multifaceted)
        @object_users.each do |object_user|
          object_users.should include(object_user)
        end
      end

      it "responds to paginate" do
        @user.object_users.scope_by_evaluation_order_type(EvaluationOrder::Multifaceted).should respond_to(:paginate)
      end
    end
  end

  describe "#score" do
    it "should return the evaluation total score" do
      pending
    end
  end

  describe "#adjustment_value" do
    it "should return the adjustment value" do
      pending
    end
  end

  describe "#adjusted_score" do
    it "should return the score involved the adjustment value" do
      pending
    end
  end

  describe "#build_evaluation_score_sheet" do
    before :each do
      @user = User.create :password => 'password',
      :password_confirmation => 'password',
      :login => 'test',
      :email => 'test@localhost.org',
      :name => "test"
    end

    describe "should return the evaluation score sheet" do
      before :each do
        Evaluation.delete_all

        @object_user = User.find_by_login 'ueyonabaru'
        @evaluation_order = EvaluationOrder.first
        @evaluation_category = EvaluationCategory.first
        @evaluation = Evaluation.create :user => @user,
                                        :object_user => @object_user,
                                        :evaluation_order => @evaluation_order

        @item_belongs = @object_user.item_group.item_belongs.
          scope_by_evaluation_category_and_order_by_evaluation_item(@evaluation_category)
        Score.delete_all
        @scores = @user.build_evaluation_score_sheet @object_user, @evaluation_category
      end

      it "should be an expected data structure" do
        # Data structure:
        #
        # [
        #  [EvaluationItem#name ,
        #   [[{Evaluator#id, Evaluator#name},
        #     [{EvaluationOrder#name, Score#point_id, Score#id}]]]]]
        #
        # Example:
        #
        # [
        #  [売上貢献,
        #   [[{user_id:やび.id, user_name:やび},
        #     [{evaluation_order_name:一次, score_point:1, score_id:1}]]]]]

        @scores.should be_a_kind_of(Array)
        @scores.should_not be_empty
        @scores.each do |score|
          score.should be_a_kind_of(Array)
          score.first.should be_a_kind_of(String)
          score.last.should be_a_kind_of(Array)
          score.last.should_not be_empty
          score.last.each do |e|
            e.should be_a_kind_of(Array)
            e.should_not be_empty
            e.first.should be_a_kind_of(Hash)
            e.first.should have_key(:user_id)
            e.first.should have_key(:user_name)
            e.last.should be_a_kind_of(Array)
            e.last.should_not be_empty
            e.last.each do |f|
              f.should be_a_kind_of(Hash)
              f.should_not be_empty
              f.should have_key(:evaluation_order_name)
              f.should have_key(:point_id)
              f.should have_key(:id)
            end
          end
        end
      end

      it "should involve item_belongs.note" do
        pending
      end

      describe "when the single evaluation exists" do
        it "should return records by evaluation_item_name correspond to evaluation_category" do
          evaluation_item_names = @scores.collect { |score| score.first }

          expected_names = @item_belongs.collect do |item_belong|
            item_belong.item.evaluation_item.name
          end

          evaluation_item_names.length.should equal(expected_names.length)

          evaluation_item_names.length.times do |n|
            evaluation_item_names[n].should == expected_names[n]
          end
        end

        it "should include the evaluator information" do
          @scores.each do |score|
            score.last.first.first[:user_name].should == @user.name
            score.last.first.first[:user_id].should equal(@user.id)
          end
        end

        it "should return records have evaluation order_name and score information" do
          @scores.collect {|score| score.last.last.last.last}.each do |score|
            score[:evaluation_order_name].should == @evaluation_order.name
            score[:point_id].should be_nil
            score[:id].should be_nil
          end
        end
      end

      describe "when the multiple evaluations exist" do
        describe "that are by same evaluator" do
          before :each do
            @evaluation_order2 = EvaluationOrder.all[1] # 二次評価
            @evaluation2 = Evaluation.create :user => @user,
                                             :object_user => @object_user,
                                             :evaluation_order => @evaluation_order2
            @scores = @user.build_evaluation_score_sheet @object_user, @evaluation_category
          end

          it "should have object_user's evaluation item names" do
            evaluation_item_names = @scores.collect { |score| score.first }

            expected_names = @item_belongs.collect do |item_belong|
              item_belong.item.evaluation_item.name
            end

            evaluation_item_names.length.should equal(expected_names.length)

            evaluation_item_names.length.times do |n|
              evaluation_item_names[n].should == expected_names[n]
            end
          end

          it "should include an evaluator" do
            @scores.each{|score| score.last.first.first[:user_id].should equal(@user.id)}
          end

          it "should include the multiple evaluations" do
            evaluations = @user.evaluations.find(:all, :conditions=>['evaluations.object_user_id = ?',@object_user],:order=>'evaluations.evaluation_order_id')

            scores = @scores.collect {|score| score.last.last.last}

            scores.each {|e| e.length.should equal(evaluations.length)}

            scores.each do |scores2|
              scores2.length.times do |n|
                scores2[n][:evaluation_order_name].should == evaluations[n].evaluation_order.name
              end
            end
          end
        end

        describe "that are not by same evaluator" do
          before :each do
            @user2 = User.create :password => 'password',
                                 :password_confirmation => 'password',
                                 :login => 'test2',
                                 :email => 'test2@localhost.org'
            @evaluation2 = Evaluation.create :user => @user2,
                                             :object_user => @object_user,
                                             :evaluation_order => @evaluation_order
            @scores = @user.build_evaluation_score_sheet @object_user, @evaluation_category
          end

          it "should include object_user's evaluation item names" do
            evaluation_item_names = @scores.collect { |score| score.first }

            expected_names = @item_belongs.collect do |item_belong|
              item_belong.item.evaluation_item.name
            end

            evaluation_item_names.length.should equal(expected_names.length)

            evaluation_item_names.length.times do |n|
              evaluation_item_names[n].should == expected_names[n]
            end
          end


          it "should include two evaluators" do
            baz = [@user, @user2]

            @scores.each do |scores_by_evaluation_item|
              evaluators_scores_attrs = scores_by_evaluation_item.last

              evaluators_scores_attrs.length.should equal(baz.length)

              evaluators_scores_attrs.length.times do |n|
                evaluator_attrs, scoers_attrs = evaluators_scores_attrs[n]

                evaluator_attrs[:user_id].should equal(baz[n].id)
              end
            end
          end

          describe "when false is set as with_others_evaluations" do
            before :each do
              @scores = @user.build_evaluation_score_sheet @object_user, @evaluation_category, false
            end

            it "should not include other's evaluatons" do
              @scores.each do |scores_by_evaluation_item|
                evaluators_scores_attrs = scores_by_evaluation_item.last
                evaluators_scores_attrs.length.should equal([@user, @user2].length - 1)
                evaluator_ids = evaluators_scores_attrs.collect {|evaluator_attrs, scoers_attrs| evaluator_attrs[:user_id]}
                evaluator_ids.should include(@user.id)
                evaluator_ids.should_not include(@user2.id)
              end

            end
          end
        end
      end
    end
  end

  describe "about users do not complete evaluations" do
    before :each do
      Evaluation.delete_all
      @user = User.first
      @object_user = User.last
      @order_1st = EvaluationOrder.find_by_name("1次評価")
      @order_2nd = EvaluationOrder.find_by_name("2次評価")
      @order_mul = EvaluationOrder.find_by_name("多面評価")
      @evaluation_first = Evaluation.create :user => @user,
                                            :object_user => @object_user,
                                            :evaluation_order => @order_1st
      @evaluation_second = Evaluation.create :user => @user,
                                             :object_user => @object_user,
                                             :evaluation_order => @order_2nd
      @evaluation_multifaceted = Evaluation.create :user => @user,
                                                   :object_user => @object_user,
                                                   :evaluation_order => @order_mul
      @user2 = User.all[1]
      @evaluation_multifaceted2 = Evaluation.create :user => @user2,
                                                    :object_user => @object_user,
                                                    :evaluation_order => @order_mul
    end

    describe ".incompletes" do
      it "should return object users's topdown evaluation items are not evaluated by item_belongs.seq column" do
        evaluation_items = @object_user.item_group.item_belongs.scope_by_evaluation_category_and_order_by_evaluation_item(*EvaluationCategory::TopDown.all).collect { |item_belong| item_belong.item.evaluation_item }

        incomplete_evaluation_items = User.incompletes(@user)
        incomplete_1st_evaluation_items = incomplete_evaluation_items.select do |e|
          e.evaluation_order_name == @order_1st.name
        end
        incomplete_1st_evaluation_items.count.should equal(evaluation_items.count)
        evaluation_items.inject(0) do |n, e|
          incomplete_1st_evaluation_items[n].evaluation_item_name.should == e.name
          n += 1
        end
        incomplete_2nd_evaluation_items = incomplete_evaluation_items.select do |e|
          e.evaluation_order_name == @order_2nd.name
        end
        incomplete_2nd_evaluation_items.count.should equal(evaluation_items.count)
        evaluation_items.inject(0) do |n, e|
          incomplete_2nd_evaluation_items[n].evaluation_item_name.should == e.name
          n += 1
        end
      end

      it "should return object users's multifaceted evaluation items are not evaluated and are sorted by item_belongs.seq column" do
        evaluation_items = @object_user.item_group.item_belongs.scope_by_evaluation_category_and_order_by_evaluation_item(*EvaluationCategory::Multifaceted.all).collect { |item_belong| item_belong.item.evaluation_item }
        incomplete_evaluation_items = User.incompletes(@user)
        incomplete_1st_evaluation_items = incomplete_evaluation_items.select do |e|
          e.evaluation_order_name == @order_mul.name
        end
        incomplete_1st_evaluation_items.count.should equal(evaluation_items.count)
        evaluation_items.inject(0) do |n, e|
          incomplete_1st_evaluation_items[n].evaluation_item_name.should == e.name
          n += 1
        end
      end

      it "should not return topdown evaluation items are evaluated" do
        point = Point.first
        @object_user.item_group.item_belongs.scope_by_evaluation_category_and_order_by_evaluation_item(*EvaluationCategory::TopDown.all).each do |item_belong|
          Score.create!(:item_belong => item_belong,
                        :evaluation => @evaluation_first,
                        :point => point)
        end
        evaluation_items = @object_user.item_group.item_belongs.scope_by_evaluation_category_and_order_by_evaluation_item(*EvaluationCategory::TopDown.all).collect { |item_belong| item_belong.item.evaluation_item }
        incomplete_evaluation_items = User.incompletes(@user)
        incomplete_1st_evaluation_items = incomplete_evaluation_items.select do |e|
          e.evaluation_order_name == @order_1st.name
        end
        incomplete_1st_evaluation_items.should be_empty
        incomplete_1st_evaluation_items = incomplete_evaluation_items.select do |e|
          e.evaluation_order_name == @order_2nd.name
        end
        incomplete_1st_evaluation_items.should_not be_empty
      end

      it "should receive multiple user ids" do
        users = User.incompletes(@user, @user2)
        users.collect { |u| u.user_name }.should include(@user.name, @user2.name)
      end

      it "should return all users do not complete evaluation when no argument passed" do
        users = User.incompletes
        users.collect { |u| u.user_name }.should include(@user.name, @user2.name)
      end
    end

    describe "#incomplete_users" do
      before :each do
        @evaluation_tree_root = EvaluationTree.find_by_user_id(@user)
        @evaluation_tree_child = EvaluationTree.find_by_user_id(@user2)
        @evaluation_tree_child.move_to_child_of @evaluation_tree_root
      end

      it "should return users under the evaluation tree do not complete evaluations" do
        incomplete_users = @user.incomplete_users
        incomplete_users.should include(@user, @user2)
        incomplete_users.each do |incomplete_user|
          incomplete_user.should respond_to(:done)
          incomplete_user.done.should be_false
        end
      end

      it "should not return users under the evaluations complete evaluations" do
        point = Point.first
        @object_user.item_group.item_belongs.scope_by_evaluation_category_and_order_by_evaluation_item(*EvaluationCategory::TopDown.all).each do |item_belong|
          Score.create!(:item_belong => item_belong,
                        :evaluation => @evaluation_first,
                        :point => point)
        end
        @object_user.item_group.item_belongs.scope_by_evaluation_category_and_order_by_evaluation_item(*EvaluationCategory::TopDown.all).each do |item_belong|
          Score.create!(:item_belong => item_belong,
                        :evaluation => @evaluation_second,
                        :point => point)
        end
        @object_user.item_group.item_belongs.scope_by_evaluation_category_and_order_by_evaluation_item(*EvaluationCategory::Multifaceted.all).each do |item_belong|
          Score.create!(:item_belong => item_belong,
                        :evaluation => @evaluation_multifaceted,
                        :point => point)
        end
        incomplete_users = @user.incomplete_users
        incomplete_users.select { |e| e == @user }.first.done.should be_true
        incomplete_users.select { |e| e == @user2 }.first.done.should be_false
      end

      it "should sort users by katakana" do
        incomplete_users = @user.incomplete_users
        [@user2, @user].sort { |a, b| a.kana <=> b.kana }.inject(0) do |n, user|
          incomplete_users[n].should == user
          n += 1
        end
      end
    end

    describe ".incompletes_to_csv" do
      it "call .incompletes with user_ids" do
        User.should_receive(:incompletes).with("1", "2", "3") { [] }
        User.incompletes_to_csv("1", "2", "3")
      end

      it "generate csv includes users do not complete evaluation" do
        csv = User.incompletes_to_csv(*@user.incomplete_users).toutf8
        csv.should match(/#{@user.name}.*#{@object_user.name}.*#{@order_1st.name}/)
        csv.should match(/#{@user.name}.*#{@object_user.name}.*#{@order_2nd.name}/)
        csv.should match(/#{@user.name}.*#{@object_user.name}.*#{@order_mul.name}/)
      end
    end
  end

  describe ".users_have_multifaceted_evaluation" do
    pending
  end

  describe ".aggregate_each_user" do
    pending
  end

  describe ".evaluation_results" do
    it "returns a hash value includes System.evaluation_term_start_at and System.evaluation_term_finish_at" do
      expected = "2010/04/01 - 2010/09/30"
      System.stub(:describe_evaluation_term => expected)
      results = User.evaluation_results
      results.should have_key(:evaluation_term)
      results[:evaluation_term].should == expected
    end

    it "returns a hash value includes EvaluationGroup::TopDown.first.weight" do
      mock_evaluation_group = mock_model(EvaluationGroup::TopDown).as_null_object.tap do |group|
        group.stub(:weight => 0.85)
      end
      EvaluationGroup::TopDown.stub(:first) { mock_evaluation_group }
      results = User.evaluation_results
      results.should have_key(:topdown_evaluation_weight)
      results[:topdown_evaluation_weight].should equal(mock_evaluation_group.weight)
    end

    it "returns a hash value includes EvaluationGroup::Multifaceted.first.weight" do
      mock_evaluation_group = mock_model(EvaluationGroup::Multifaceted).as_null_object.tap do |group|
        group.stub(:weight => 0.15)
      end
      EvaluationGroup::Multifaceted.stub(:first) { mock_evaluation_group }
      results = User.evaluation_results
      results.should have_key(:multifaceted_evaluation_weight)
      results[:multifaceted_evaluation_weight].should equal(mock_evaluation_group.weight)
    end

    it "returns a hash value includes the evaluation results of each users" do
      results = User.evaluation_results
      results.should have_key(:users)
      results[:users].should be_a_kind_of(Array)
    end
  end

  describe "#interviews" do
    before :each do
      Interview.delete_all
      @evaluation = Evaluation.first
      @object_user = @evaluation.object_user
    end

    describe "#done?" do
      it "should be false when interviews are not existing" do
        @object_user.interviews.done?.should be_false
      end


      it "should be false when all interviews is not done" do
        interview = Interview.new :done_at => nil
        @evaluation.interview = interview
        @object_user.interviews.done?.should be_false
      end

      it "should be true when one of interviews is done" do
        interview = Interview.new :done_at => DateTime.now
        @evaluation.interview = interview
        @object_user.interviews.done?.should be_true
      end
    end
  end

  describe ".make_users_interviews!" do
    before :each do
      @users = User.all
      User.make_users_interviews!(@users)
    end

    it "should respond to interview_done" do
      @users.each do |user|
        user.should respond_to(:interview_done?)
      end
    end
  end

  describe ".all_evaluatees" do
    before :each do
      Evaluation.delete_all
      @object_user = User.last
      Evaluation.create(:user => User.first, :object_user => @object_user, :evaluation_order => EvaluationOrder.first)
    end

    it "returns users have the passive evaluations" do
      User.all_evaluatees.should include(@object_user)
    end
  end

end
