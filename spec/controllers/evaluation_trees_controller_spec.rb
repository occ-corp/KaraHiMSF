# -*- coding: utf-8 -*-
require 'spec_helper'

describe EvaluationTreesController do

  def mock_evaluation_tree(stubs={})
    @mock_evaluation_tree ||= mock_model(EvaluationTree, stubs).as_null_object
  end

  def mock_evaluation_tree_child(stubs={})
    @mock_evaluation_tree_child ||= mock_model(EvaluationTree, stubs).as_null_object
  end

  describe "GET index" do
    it "renders the 'index' template" do
      get :index
      response.should render_template("index")
    end

    describe "with Ajax request" do
      it "should response JSON" do
        EvaluationTree.should_receive(:to_sexpr) { [mock_evaluation_tree] }
        @controller.should_receive(:render).with(no_args)
        @controller.should_receive(:render).with({:json => [mock_evaluation_tree]} )
        xhr :get, :index
      end

    end
  end

  describe "GET show" do
    it "assigns the requested evaluation_tree as @evaluation_tree" do
      EvaluationTree.stub(:find).with("37") { mock_evaluation_tree }
      get :show, :id => "37", :format => :json
      assigns(:evaluation_tree).should be(mock_evaluation_tree)
    end

    it "should render no template" do
      EvaluationTree.stub(:find).with("37") { mock_evaluation_tree }
      get :show, :id => "37", :format => :json
      response.should render_template(nil)
    end

    it "should response JSON" do
      mock_evaluation_tree.stub(:children) { [] }
      EvaluationTree.stub(:find).with("37") { mock_evaluation_tree }
      @controller.should_receive(:render).with(no_args)
      @controller.should_receive(:render).with({:json => []})
      get :show, :id => "37", :format => :json
    end
  end

  describe "GET new" do
    it "assigns a new evaluation_tree as @evaluation_tree" do
      EvaluationTree.stub(:new) { mock_evaluation_tree }
      get :new
      assigns(:evaluation_tree).should be(mock_evaluation_tree)
    end
  end

  describe "GET edit" do
    it "assigns the requested evaluation_tree as @evaluation_tree" do
      EvaluationTree.stub(:find).with("37") { mock_evaluation_tree }
      get :edit, :id => "37"
      assigns(:evaluation_tree).should be(mock_evaluation_tree)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created evaluation_tree as @evaluation_tree" do
        EvaluationTree.stub(:new).with({'these' => 'params'}) { mock_evaluation_tree(:save => true) }
        post :create, :evaluation_tree => {'these' => 'params'}
        assigns(:evaluation_tree).should be(mock_evaluation_tree)
      end

      it "redirects to the created evaluation_tree" do
        EvaluationTree.stub(:new) { mock_evaluation_tree(:save => true) }
        post :create, :evaluation_tree => {}
        response.should redirect_to(evaluation_tree_url(mock_evaluation_tree))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved evaluation_tree as @evaluation_tree" do
        EvaluationTree.stub(:new).with({'these' => 'params'}) { mock_evaluation_tree(:save => false) }
        post :create, :evaluation_tree => {'these' => 'params'}
        assigns(:evaluation_tree).should be(mock_evaluation_tree)
      end

      it "re-renders the 'new' template" do
        EvaluationTree.stub(:new) { mock_evaluation_tree(:save => false) }
        post :create, :evaluation_tree => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do
    it "should call EvaluationTree.tranverse_tree_recursively_and_update" do
      @controller.should_receive(:update_evaluation_trees_old)
      put :update, :id => "dummy", :evaluation_trees => [[1, []]].to_json, :format => :json
    end

    it "should response JSON" do
      @controller.should_receive(:render).with(no_args)
      @controller.should_receive(:render).with({:json => ""})
      put :update, :id => "dummy", :evaluation_trees => [].to_json, :format => :json
    end
  end

  describe "PUT confirm" do
    before :each do
      @mock_evaluation = mock_model(Evaluation, { })
    end

    it "should call EvaluationTree.tranverse_tree_recursively_and_update every EvaluationTrees given by params[:evaluation_trees]" do
      EvaluationTree.should_receive(:tranverse_tree_recursively_and_update).with([1, []]) { [@mock_evaluation] }
      assigns(:evaluations).should == [@mock_evaluation]
    end

    it "should call EvaluationTree.make_evaluation_tree_unselect every EvaluationTrees given by params[:deleted_evaluation_trees]" do

      EvaluationTree.stub(:find) { [mock_evaluation_tree] }
      EvaluationTree.should_receive(:make_evaluation_tree_unselect).with(mock_evaluation_tree) { [@mock_evaluation] }
      put :confirm, :deleted_evaluation_trees => [1].to_json

      assigns(:evaluations).should == [@mock_evaluation]
    end

    it "should response the unprocessable_entity" do
      put :confirm
      response.status_message.should == "Unprocessable Entity"
    end

    it "should render _confirm" do
      put :confirm
      response.should render_template("_confirm")
    end
  end

  describe "#build_yaml_buffer" do
    describe "when csv file is empty" do
      it "returns empty string" do
        yaml = controller.class.build_yaml_buffer(Tempfile.open("build_evaluation_tree_from_csv"), EvaluationTree::TopDown)
        yaml.should be_kind_of(String)
        yaml.should be_empty
      end
    end

    describe "when the note column does not exist in csv head" do
      before :each do
        controller.params[:file] = @tempfile
      end
      it "should raise an exception" do
        tempfile = Tempfile.open("build_evaluation_tree_from_csv") do |io|
          io << <<-EOS
評価組システムID,評価フラグ(FALSE=未評価),対象外フラグ(TRUE=対象外),社員ID,社員名,所属部課,役職,職種,ログイン名
EOS
        end
        lambda {
          controller.class.build_yaml_buffer tempfile, EvaluationTree::TopDown
        }.should raise_error(RuntimeError)
      end
    end

    describe "when csv file is valid" do
      before :each do
        @klass = EvaluationTree::TopDown
        @tempfile = Tempfile.open("build_evaluation_tree_from_csv") do |io|
          # |\- iwamichi
          # |    \
          # |     \- ueunten
          # |         \
          # |          \- ueno
          io << <<-EOS
評価組システムID,評価フラグ(FALSE=未評価),対象外フラグ(TRUE=対象外),社員ID,社員名,所属部課,役職,職種,備考,ログイン名
#{user_evaluation_tree_id "iwamichi"},,,333,岩道光,役員(営業戦略部),常務取締役,管理職,,iwamichi
#{user_evaluation_tree_id "ueunten"},,,588,上運天嘉則,営業戦略部技術支援課,部長,管理職,,,ueunten
#{user_evaluation_tree_id "ueno"},,,7218,上之屋克洋,営業戦略部技術支援課,ﾘｰﾀﾞ,営業戦略技術支援,,,,ueno
EOS
        end
        controller.params[:file] = @tempfile
        controller.instance_eval("@klass = #{@klass}")
      end

      it "returns buffer formated yaml" do
        yaml = <<EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    #{user_evaluation_tree_id "ueno"}:
EOS
        controller.class.send(:build_yaml_buffer, @tempfile, @klass).should == yaml
      end
    end
  end

  describe "#confirm_or_update" do
    before :each do
      Evaluation.delete_all
      @evaluation_order_1st = EvaluationOrder.find_by_name("1次評価")
      @evaluation_order_2nd = EvaluationOrder.find_by_name("2次評価")
    end

    describe "when true is passed as confirm argument" do
      describe "on topdown evaluation" do
        before :each do
          @klass = EvaluationTree::TopDown
          controller.instance_eval("@klass = #{@klass}")
          # |\- iwamichi
          # |    |
          # |     \- ueunten
          # |         |
          # |          \- ueno
          # |         |
          # |          \- ueyonabaru
          # |         |
          # |          \- urasaki
          controller.class.stub(:build_yaml_buffer) {
            <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    #{user_evaluation_tree_id "ueno"}:
    #{user_evaluation_tree_id "ueyonabaru"}:
    #{user_evaluation_tree_id "urasaki"}:
EOS
          }
          controller.send(:build_evaluation_tree_from_csv)
        end

        it "does not change the evaluation tree" do
          controller.send(:confirm_or_update, true)
          EvaluationTree.all.each do |evaluation_tree|
            evaluation_tree.root?.should be_true
            evaluation_tree.selected.should be_false
          end
        end

        it "generates evaluations respond to :user and :object_user" do
          controller.send(:confirm_or_update, true)
          assigns(:evaluations).each do |evaluation|
            evaluation.should respond_to(:user)
            user = evaluation.user
            user.should be_kind_of(Object)
            user.should respond_to(:name)
            user.should respond_to(:login)
            evaluation.should respond_to(:object_user)
            object_user = evaluation.object_user
            object_user.should be_kind_of(Object)
            object_user.should respond_to(:login)
          end
        end

        it "generates evaluations not saved" do
          controller.send(:confirm_or_update, true)
          Evaluation.all.should be_empty
        end

        it "generates expected evaluations" do
          controller.send(:confirm_or_update, true)
          # expected evaluations (parenthesis is object's status)
          #
          # iwamichi --1st--> ueunten  (created)
          #         --2nd--> ueunten  (created)
          #         --2nd--> ueno (created)
          #         --2nd--> ueyonabaru   (created)
          #         --2nd--> urasaki   (created)
          # ueunten  --1st--> ueno (created)
          #         --1st--> ueyonabaru   (created)
          #         --1st--> urasaki   (created)
          assigns(:evaluations).select { |e| e.user.login == "iwamichi" }.select { |e|
            e.evaluation_order == @evaluation_order_1st
          }.collect { |e| e.object_user.login }.should include("ueunten")
          assigns(:evaluations).select { |e| e.user.login == "iwamichi" }.select { |e|
            e.evaluation_order == @evaluation_order_2nd
          }.collect { |e| e.object_user.login }.should include("ueunten", "ueno", "ueyonabaru", "urasaki")
          assigns(:evaluations).select { |e| e.user.login == "ueunten" }.select { |e|
            e.evaluation_order == @evaluation_order_1st
          }.collect { |e| e.object_user.login }.should include("ueno", "ueyonabaru", "urasaki")
          assigns(:evaluations).each { |e| e.modification == :created }
        end

        it "regenerates expected evaluations when the tree changed" do
          controller.send :confirm_or_update
          # \- iwamichi
          #     |
          #     |\- ueunten
          #     |    |
          #     |     \- ueno
          #     |
          #      \- ushiduka
          #          |
          #           \- ueyonabaru
          #          |
          #           \- urasaki
          controller.class.stub(:build_yaml_buffer) {
            <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    #{user_evaluation_tree_id "ueno"}:
  #{user_evaluation_tree_id "ushiduka"}:
    #{user_evaluation_tree_id "ueyonabaru"}:
    #{user_evaluation_tree_id "urasaki"}:
EOS
          }
          controller.send(:build_evaluation_tree_from_csv)
          controller.send(:confirm_or_update, true)

          # changed evaluations only are expected
          #
          # iwamichi  --1st--> ushiduka (created)
          #          --2nd--> ushiduka (created)
          # ueunten   --1st--> ueyonabaru    (destroyed)
          #          --1st--> urasaki    (destroyed)
          # ushiduka --1st--> ueyonabaru    (created)
          #          --1st--> urasaki    (created)
          assigns(:evaluations).count.should equal(6)

          assigns(:evaluations).select { |e| e.user.login == "iwamichi" }.select { |e|
            e.evaluation_order == @evaluation_order_1st
          }.collect { |e|
            e.modification.should == :created
            e.object_user.login
          }.should include("ushiduka")

          assigns(:evaluations).select { |e| e.user.login == "iwamichi" }.select { |e|
            e.evaluation_order == @evaluation_order_2nd
          }.collect { |e|
            e.modification.should == :created
            e.object_user.login
          }.should include("ushiduka")

          assigns(:evaluations).select { |e| e.user.login == "ueunten" }.select { |e|
            e.evaluation_order == @evaluation_order_1st
          }.collect { |e|
            e.modification.should == :destroyed
            e.object_user.login
          }.should include("ueyonabaru", "urasaki")

          assigns(:evaluations).select { |e| e.user.login == "ushiduka" }.select { |e|
            e.evaluation_order == @evaluation_order_1st
          }.collect { |e|
            e.modification.should == :created
            e.object_user.login
          }.should include("ueyonabaru", "urasaki")
        end
      end

      describe "on multifaceted evaluation" do
        before :each do
          @klass = EvaluationTree::Multifaceted
          controller.instance_eval("@klass = #{@klass}")
          # |\- ueunten
          # |    |
          # |    \-group
          # |       |
          # |        \- ueno
          # |       |
          # |        \- ueyonabaru
          # |       |
          # |        \- urasaki
          controller.class.stub(:build_yaml_buffer) {
            <<-EOS
#{user_evaluation_tree_id "ueunten"}:
  group1:
    #{user_evaluation_tree_id "ueno"}:
    #{user_evaluation_tree_id "ueyonabaru"}:
    #{user_evaluation_tree_id "urasaki"}:
EOS
          }
          controller.send(:build_evaluation_tree_from_csv)
        end

        it "generates evaluations not saved" do
          controller.send(:confirm_or_update, true)
          Evaluation.all.should be_empty
        end

        it "generates expected evaluations" do
          controller.send(:confirm_or_update, true)
          # expected evaluations (parenthesis is object's status)
          #
          # ueno -> ueno (created)
          #            ueyonabaru   (created)
          #            urasaki   (created)
          #            ueunten  (created)
          # ueyonabaru   -> ueno (created)
          #            ueyonabaru   (created)
          #            urasaki   (created)
          #            ueunten  (created)
          # urasaki   -> ueno (created)
          #            ueyonabaru   (created)
          #            urasaki   (created)
          #            ueunten  (created)
          assigns(:evaluations).count equal(12)
          evaluators = ["ueno", "ueyonabaru", "urasaki"]
          evaluatees = ["ueno", "ueyonabaru", "urasaki", "ueunten"]
          evaluators.each do |evaluator|
            assigns(:evaluations).select { |e|
              e.user.login == evaluator
            }.collect { |e|
              e.object_user.login
            }.should include(*evaluatees)
          end
        end

        it "regenerates expected evaluations when the tree changed" do
          controller.send(:confirm_or_update)
          # |\- ueunten
          # |    |
          # |    \-ushiduka
          # |       |
          # |       \-group
          # |          |
          # |           \- ueno
          # |          |
          # |           \- ueyonabaru
          # |          |
          # |           \- urasaki
          controller.class.stub(:build_yaml_buffer) {
            <<-EOS
#{user_evaluation_tree_id "ueunten"}:
  group1:
    #{user_evaluation_tree_id "ueno"}:
    #{user_evaluation_tree_id "ueyonabaru"}:
    #{user_evaluation_tree_id "urasaki"}:
#{user_evaluation_tree_id "urasaki"}:
EOS
          }
          controller.send(:build_evaluation_tree_from_csv)
          controller.send(:confirm_or_update, true)
          # expected evaluations (parenthesis is object's status)
          #
          # ushiduka -> ueunten   (created)
          # ueno  -> ueunten   (removed)
          #          -> ushiduka (created)
          # ueyonabaru    -> ueunten   (removed)
          #          -> ushiduka (created)
          # urasaki    -> ueunten   (removed)
          #          -> ushiduka (created)
          # assigns(:evaluations).count equal(7)
          pending
        end
      end
    end

    describe "when true is not passed as confirm argument" do
      describe "on topdown evaluation" do
        before :each do
          @klass = EvaluationTree::TopDown
          controller.instance_eval("@klass = #{@klass}")
          # |\- iwamichi
          # |    |
          # |     \- ueunten
          # |         |
          # |          \- ueno
          # |         |
          # |          \- ueyonabaru
          # |         |
          # |          \- urasaki
          # |
          # |\- ushiduka
          controller.class.stub(:build_yaml_buffer) {
            <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    #{user_evaluation_tree_id "ueno"}:
    #{user_evaluation_tree_id "ueyonabaru"}:
    #{user_evaluation_tree_id "urasaki"}:
#{user_evaluation_tree_id "ushiduka"}:
EOS
          }
          controller.send(:build_evaluation_tree_from_csv)
          controller.send(:confirm_or_update)
        end

        it "generates expected evaluations" do
          # expected evaluations:
          #
          # iwamichi --1st--> ueunten
          #         --2nd--> ueunten
          #         --2nd--> ueno
          #         --2nd--> ueyonabaru
          #         --2nd--> urasaki
          # ueunten  --1st--> ueno
          #         --1st--> ueyonabaru
          #         --1st--> urasaki
          Evaluation.count.should be(8)

          evaluation_order_1st = EvaluationOrder.find_by_name("1次評価")
          evaluation_order_2nd = EvaluationOrder.find_by_name("2次評価")

          evaluations = Evaluation.
            only_matches_evaluation_orders(evaluation_order_1st).
            find_all_by_user_id(User.find_by_login("iwamichi"))

          evaluations.count.should be(1)
          evaluations.collect { |e| e.object_user.login }.should include("ueunten")

          evaluations = Evaluation.
            only_matches_evaluation_orders(evaluation_order_2nd).
            find_all_by_user_id(User.find_by_login("iwamichi"))

          evaluations.count.should be(4)
          evaluations.collect { |e| e.object_user.login }.should include("ueunten", "ueno", "ueyonabaru", "urasaki")

          evaluations = Evaluation.
            only_matches_evaluation_orders(evaluation_order_1st).
            find_all_by_user_id(User.find_by_login("ueunten"))

          evaluations.count.should be(3)
          evaluations.collect { |e| e.object_user.login }.should include("ueno", "ueyonabaru", "urasaki")

          evaluations = Evaluation.
            only_matches_evaluation_orders(evaluation_order_2nd).
            find_all_by_user_id(User.find_by_login("ueunten"))

          evaluations.should be_empty
        end

        it "should set true to selected-column of activated EvaluationTrees" do
          evaluation_trees = EvaluationTree.find(JSON.parse(controller.params[:evaluation_trees]).flatten)
          evaluation_trees.each do |e|
            e.selected.should be_true
          end

          all_evaluation_trees = EvaluationTree.all
          evaluation_trees.each { |e| all_evaluation_trees.delete e }

          all_evaluation_trees.each do |e|
            e.root?.should be_true
            e.selected.should be_false
          end
        end

        it "should remove evaluations and EvaluationTrees when sub tree removed" do
          # |\- iwamichi
          # |    \
          # |     \- ueno
          controller.class.stub(:build_yaml_buffer) {
            <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueno"}:
EOS
          }
          controller.send(:build_evaluation_tree_from_csv)
          controller.send(:confirm_or_update)

          root = user_evaluation_tree("iwamichi")
          root.root?.should be_true
          user_evaluation_tree("ueno").parent.should == root

          evaluation_trees = EvaluationTree::TopDown.find :all, :include => :user, :conditions => ["users.login in(?)", ["iwamichi", "ueno"]]
          evaluation_trees.each { |e| e.selected.should be_true }
          all_evaluation_trees = EvaluationTree::TopDown.all
          evaluation_trees.each { |e| all_evaluation_trees.delete e }
          all_evaluation_trees.each do |e|
            e.root?.should be_true
            e.selected.should be_false
          end

          # Expected evaluations:
          #
          # iwamichi --1st--> ueno
          #         --2nd--> ueno
          Evaluation.count.should be(2)

          evaluations = Evaluation.
            only_matches_evaluation_orders(EvaluationOrder.find_by_name("1次評価")).
            find_all_by_user_id(User.find_by_login("iwamichi"))

          evaluations.count.should be(1)
          evaluations.collect { |e| e.object_user.login }.should include("ueno")

          evaluations = Evaluation.
            only_matches_evaluation_orders(EvaluationOrder.find_by_name("2次評価")).
            find_all_by_user_id(User.find_by_login("iwamichi"))

          evaluations.count.should be(1)
          evaluations.collect { |e| e.object_user.login }.should include("ueno")
        end

        it "should regenerate evaluations when evaluation tree changed" do
          # |\- iwamichi
          # |    |
          # |    |\- ueunten
          # |    |    |
          # |    |     \- ueno
          # |    |    |
          # |    |     \- ueyonabaru
          # |    |
          # |     \- ushiduka
          # |         |
          # |          \- urasaki
          controller.class.stub(:build_yaml_buffer) {
            <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    #{user_evaluation_tree_id "ueno"}:
    #{user_evaluation_tree_id "ueyonabaru"}:
  #{user_evaluation_tree_id "ushiduka"}:
    #{user_evaluation_tree_id "urasaki"}:
EOS
          }
          controller.send(:build_evaluation_tree_from_csv)
          controller.send(:confirm_or_update)

          # Expected evaluations
          #
          # iwamichi  --1st--> ueunten
          #          --1st--> ushiduka
          #          --2nd--> ueunten
          #          --2nd--> ushiduka
          #          --2nd--> ueno
          #          --2nd--> ueyonabaru
          #          --2nd--> urasaki
          # ueunten   --1st--> ueno
          #          --1st--> ueyonabaru
          # ushiduka --1st--> urasaki
          evaluation_order_1st = EvaluationOrder.find_by_name("1次評価")
          evaluation_order_2nd = EvaluationOrder.find_by_name("2次評価")

          evaluations = Evaluation.
            only_matches_evaluation_orders(evaluation_order_1st).
            find_all_by_user_id(User.find_by_login("iwamichi"))
          evaluations.count.should be(2)
          evaluations.collect { |e| e.object_user.login }.should include("ueunten", "ushiduka")
          evaluations = Evaluation.
            only_matches_evaluation_orders(evaluation_order_2nd).
            find_all_by_user_id(User.find_by_login("iwamichi"))
          evaluations.count.should be(5)
          evaluations.collect { |e| e.object_user.login }.should include("ueunten", "ushiduka", "ueno", "ueyonabaru", "urasaki")
          evaluations = Evaluation.
            only_matches_evaluation_orders(evaluation_order_1st).
            find_all_by_user_id(User.find_by_login("ueunten"))
          evaluations.count.should be(2)
          evaluations.collect { |e| e.object_user.login }.should include("ueno", "ueyonabaru")
          evaluations = Evaluation.
            only_matches_evaluation_orders(evaluation_order_2nd).
            find_all_by_user_id(User.find_by_login("ueunten"))
          evaluations.should be_empty
          evaluations = Evaluation.
            only_matches_evaluation_orders(evaluation_order_1st).
            find_all_by_user_id(User.find_by_login("ushiduka"))
          evaluations.count.should be(1)
          evaluations.collect { |e| e.object_user.login }.should include("urasaki")
          evaluations = Evaluation.
            only_matches_evaluation_orders(evaluation_order_2nd).
            find_all_by_user_id(User.find_by_login("ushiduka"))
          evaluations.should be_empty
        end

        describe "when sub tree moved to root" do
          before :each do
            controller.send :confirm_or_update
            # |\- iwamichi
            # |
            # |\- ueunten
            # |    |
            # |     \- ueno
            # |    |
            # |     \- ueyonabaru
            # |    |
            # |     \- urasaki
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
#{user_evaluation_tree_id "ueunten"}:
  #{user_evaluation_tree_id "ueno"}:
  #{user_evaluation_tree_id "ueyonabaru"}:
  #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send(:build_evaluation_tree_from_csv)
            controller.send(:confirm_or_update)
          end

          it "remove evaluations to the top of sub tree and it's children" do
            # It is expected that below evaluations removed.
            #
            # iwamichi --1st--> ueunten
            #         --2nd--> ueunten
            #         --2nd--> ueno
            #         --2nd--> ueyonabaru
            #         --2nd--> urasaki
            Evaluation.find_all_by_user_id(User.find_by_login("iwamichi")).count.should equal(0)
          end

          it "create evaluations to the children" do
            # Expected evaluations
            #
            # ueunten --1st--> ueno
            #        --1st--> ueyonabaru
            #        --1st--> urasaki
            #        --2nd--> ueno
            #        --2nd--> ueyonabaru
            #        --2nd--> urasaki
            evaluations = Evaluation.only_matches_evaluation_orders(EvaluationOrder.find_by_name("1次評価")).find_all_by_user_id(User.find_by_login("ueunten"))
            evaluations.count.should equal(3)
            evaluations.collect { |e|
              e.object_user.login
            }.should include("ueno", "ueyonabaru", "urasaki")

            evaluations = Evaluation.only_matches_evaluation_orders(EvaluationOrder.find_by_name("2次評価")).find_all_by_user_id(User.find_by_login("ueunten"))
            evaluations.count.should equal(3)
            evaluations.collect { |e|
              e.object_user.login
            }.should include("ueno", "ueyonabaru", "urasaki")
          end
        end

        describe "when sub tree moved to root is foled" do
          before :each do
            controller.send :confirm_or_update
            # |\- iwamichi
            # |
            # |\- ueunten
            # |    |
            # |     \- ueno
            # |    |
            # |     \- ueyonabaru
            # |    |
            # |     \- urasaki
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
#{user_evaluation_tree_id "ueunten"}:
EOS
            }
            controller.send(:build_evaluation_tree_from_csv)
            controller.params.delete :deleted_evaluation_trees
            controller.send(:confirm_or_update)
          end

          it "remove evaluations to the top of sub tree and it's children" do
            Evaluation.find_all_by_user_id(User.find_by_login("iwamichi")).count.should equal(0)
          end

          it "create evaluations to the children" do
            # Expected evaluations
            #
            # ueunten --1st--> ueno
            #        --1st--> ueyonabaru
            #        --1st--> urasaki
            #        --2nd--> ueno
            #        --2nd--> ueyonabaru
            #        --2nd--> urasaki
            Evaluation.count.should equal(6)

            evaluations = Evaluation.only_matches_evaluation_orders(EvaluationOrder.find_by_name("1次評価")).find_all_by_user_id(User.find_by_login("ueunten"))
            evaluations.count.should equal(3)
            evaluations.collect { |e|
              e.object_user.login
            }.should include("ueno", "ueyonabaru", "urasaki")

            evaluations = Evaluation.only_matches_evaluation_orders(EvaluationOrder.find_by_name("2次評価")).find_all_by_user_id(User.find_by_login("ueunten"))
            evaluations.count.should equal(3)
            evaluations.collect { |e|
              e.object_user.login
            }.should include("ueno", "ueyonabaru", "urasaki")
          end
        end

        describe "when sub tree moved to child of another parent" do
          before :each do
            # |\- iwamichi
            # |
            # |\- ushiduka
            # |    |
            # |     \- ueunten
            # |         |
            # |          \- ueno
            # |         |
            # |          \- ueyonabaru
            # |         |
            # |          \- urasaki
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
#{user_evaluation_tree_id "ushiduka"}:
  #{user_evaluation_tree_id "ueunten"}:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send(:build_evaluation_tree_from_csv)
            controller.send(:confirm_or_update)
          end

          it "remove evaluations to the top of sub tree and it's children" do
            Evaluation.find_all_by_user_id(User.find_by_login("iwamichi")).count.should equal(0)
          end

          it "generates expected evaluations" do
            # Expected evaluations
            #
            # ushiduka --1st--> ueunten
            #          --2nd--> ueunten
            #          --2nd--> ueno
            #          --2nd--> ueyonabaru
            #          --2nd--> urasaki
            # ueunten   --1st--> ueyonabaru
            #          --1nd--> ueno
            #          --1nd--> urasaki
            Evaluation.count.should equal(8)
            evaluations = Evaluation.only_matches_evaluation_orders(EvaluationOrder.find_by_name("1次評価")).find_all_by_user_id(User.find_by_login("ushiduka"))
            evaluations.count.should equal(1)
            evaluations.collect { |e|
              e.object_user.login
            }.should include("ueunten")
            evaluations = Evaluation.only_matches_evaluation_orders(EvaluationOrder.find_by_name("2次評価")).find_all_by_user_id(User.find_by_login("ushiduka"))
            evaluations.count.should equal(4)
            evaluations.collect { |e|
              e.object_user.login
            }.should include("ueunten", "ueno", "ueyonabaru", "urasaki")
            evaluations = Evaluation.only_matches_evaluation_orders(EvaluationOrder.find_by_name("1次評価")).find_all_by_user_id(User.find_by_login("ueunten"))
            evaluations.count.should equal(3)
            evaluations.collect { |e|
              e.object_user.login
            }.should include("ueno", "ueyonabaru", "urasaki")
            evaluations = Evaluation.only_matches_evaluation_orders(EvaluationOrder.find_by_name("2次評価")).find_all_by_user_id(User.find_by_login("ueunten"))
            evaluations.count.should equal(0)
          end
        end

        describe "when sub tree moved to child of another parent is folded" do
          before :each do
            # |\- iwamichi
            # |
            # |\- ushiduka
            # |    |
            # |     \- ueunten
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
#{user_evaluation_tree_id "ushiduka"}:
  #{user_evaluation_tree_id "ueunten"}:
EOS
            }
            controller.send(:build_evaluation_tree_from_csv)
            controller.params.delete :deleted_evaluation_trees
            controller.send(:confirm_or_update)
          end

          it "remove original evaluations to the top of sub tree and it's children" do
            Evaluation.find_all_by_user_id(User.find_by_login("iwamichi")).count.should equal(0)
          end

          it "generates expected evaluations" do
            # Expected evaluations
            #
            # ushiduka --1st--> ueunten
            #          --2nd--> ueunten
            #          --2nd--> ueno
            #          --2nd--> ueyonabaru
            #          --2nd--> urasaki
            # ueunten   --1st--> ueyonabaru
            #          --1nd--> ueno
            #          --1nd--> urasaki
            Evaluation.count.should equal(8)
            evaluations = Evaluation.only_matches_evaluation_orders(EvaluationOrder.find_by_name("1次評価")).find_all_by_user_id(User.find_by_login("ushiduka"))
            evaluations.count.should equal(1)
            evaluations.collect { |e|
              e.object_user.login
            }.should include("ueunten")
            evaluations = Evaluation.only_matches_evaluation_orders(EvaluationOrder.find_by_name("2次評価")).find_all_by_user_id(User.find_by_login("ushiduka"))
            evaluations.count.should equal(4)
            evaluations.collect { |e|
              e.object_user.login
            }.should include("ueunten", "ueno", "ueyonabaru", "urasaki")
            evaluations = Evaluation.only_matches_evaluation_orders(EvaluationOrder.find_by_name("1次評価")).find_all_by_user_id(User.find_by_login("ueunten"))
            evaluations.count.should equal(3)
            evaluations.collect { |e|
              e.object_user.login
            }.should include("ueno", "ueyonabaru", "urasaki")
            evaluations = Evaluation.only_matches_evaluation_orders(EvaluationOrder.find_by_name("2次評価")).find_all_by_user_id(User.find_by_login("ueunten"))
            evaluations.count.should equal(0)
          end

        end

      end

      describe "on multifaceted evaluation" do
        before :each do
          @klass = EvaluationTree::Multifaceted
          controller.instance_eval("@klass = #{@klass}")
        end

        describe "when a new group created" do
          before :each do
            # Multifaceted evaluation tree before change
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  group1:
    #{user_evaluation_tree_id "ueunten"}:
    #{user_evaluation_tree_id "ueno"}:
    #{user_evaluation_tree_id "ueyonabaru"}:
    #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
            @evaluations_before_change = Evaluation.all
            # Multifaceted evaluation tree after change
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  group1:
    #{user_evaluation_tree_id "ueunten"}:
    #{user_evaluation_tree_id "ushiduka"}:
    #{user_evaluation_tree_id "ura"}:
  #{@klass.no_user_assigned_only.first.id}:
    #{user_evaluation_tree_id "ueno"}:
    #{user_evaluation_tree_id "ueyonabaru"}:
    #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
          end

          it "should generate expected evaluations" do
            group_users = ["ueunten", "ushiduka", "ura"]
            object_users = ["iwamichi", "ueunten", "ushiduka", "ura"]
            group_users.each do |login|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(login))
              evaluations.collect { |e| e.object_user.login }.should include(*object_users)
            end
            group_users = ["ueno", "ueyonabaru", "urasaki"]
            object_users = ["iwamichi", "ueno", "ueyonabaru", "urasaki"]
            group_users.each do |login|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(login))
              evaluations.collect { |e| e.object_user.login }.should include(*object_users)
            end
            users = ["iwamichi"]
            object_users = ["iwamichi"]
            users.each do |login|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(login))
              evaluations.collect { |e| e.object_user.login }.should include(*object_users)
            end
          end

          it "should remove expected evaluations" do
            evaluations = collect_evaluations_match_user_and_object_user(@evaluations_before_change, ["ueunten"], ["ueno", "ueyonabaru", "urasaki"])
            evaluations.each do |evaluation|
              Evaluation.exists?(evaluation).should be_false
            end
            evaluations = collect_evaluations_match_user_and_object_user(@evaluations_before_change, ["ueno"], ["ueunten"])
            evaluations.each do |evaluation|
              Evaluation.exists?(evaluation).should be_false
            end
            evaluations = collect_evaluations_match_user_and_object_user(@evaluations_before_change, ["ueyonabaru"], ["ueunten"])
            evaluations.each do |evaluation|
              Evaluation.exists?(evaluation).should be_false
            end
            evaluations = collect_evaluations_match_user_and_object_user(@evaluations_before_change, ["urasaki"], ["ueunten"])
            evaluations.each do |evaluation|
              Evaluation.exists?(evaluation).should be_false
            end
          end

          it "should keep round robin evaluations" do
            evaluations = collect_evaluations_match_user_and_object_user(@evaluations_before_change, ["ueno", "ueyonabaru", "urasaki"], ["ueno", "ueyonabaru", "urasaki"])
            evaluations.each do |e|
              Evaluation.exists?(e).should be_true
              Evaluation.count(:joins => "left join users on users.id = evaluations.user_id left join users object_users on object_users.id = evaluations.object_user_id", :conditions => ["users.login = ? and object_users.login = ?", e.user.login, e.object_user.login]).should equal(1)
            end
          end
        end

        describe "when a node moved" do
          it "should generate expected evaluations when a node has a group moved under another parent" do
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    group1:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
#{user_evaluation_tree_id "ushiduka"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update

            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
#{user_evaluation_tree_id "ushiduka"}:
  #{user_evaluation_tree_id "ueunten"}:
    #{@klass.no_user_assigned_only.first.id}:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update

            group_users = ["ueno", "ueyonabaru", "urasaki"]
            object_users = ["ueunten", "ueno", "ueyonabaru", "urasaki"]
            group_users.each do |login|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(login))
              evaluations.collect { |e| e.object_user.login }.should include(*object_users)
            end
          end

          it "should remove self-evaluation of parent becomes having number of passive evaluations less than 2" do
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
  #{user_evaluation_tree_id "ueno"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
            User.find_by_login("iwamichi").has_self_evaluation?.should be_true
            User.find_by_login("ueunten").has_self_evaluation?.should be_false
            User.find_by_login("ueno").has_self_evaluation?.should be_false

            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
#{user_evaluation_tree_id "ueno"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
            User.find_by_login("iwamichi").has_self_evaluation?.should be_false
            User.find_by_login("ueunten").has_self_evaluation?.should be_false
            User.find_by_login("ueno").has_self_evaluation?.should be_false
          end

          it "should generate self-evaluation of parent becomes having number of passive evaluation more than 1" do
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
#{user_evaluation_tree_id "ueno"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
            User.find_by_login("iwamichi").has_self_evaluation?.should be_false
            User.find_by_login("ueunten").has_self_evaluation?.should be_false
            User.find_by_login("ueno").has_self_evaluation?.should be_false

            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
  #{user_evaluation_tree_id "ueno"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
            User.find_by_login("iwamichi").has_self_evaluation?.should be_true
            User.find_by_login("ueunten").has_self_evaluation?.should be_false
            User.find_by_login("ueno").has_self_evaluation?.should be_false
          end

          describe "when the source group has number of children less than 3" do
            before :each do
              controller.class.stub(:build_yaml_buffer) {
                <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    group1:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
EOS
              }
              controller.send :build_evaluation_tree_from_csv
              controller.send :confirm_or_update

              @evaluations_before_change = Evaluation.all

              controller.class.stub(:build_yaml_buffer) {
                <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    #{@klass.no_user_assigned_only.first.id}:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
  #{user_evaluation_tree_id "urasaki"}:
EOS
              }
              controller.send :build_evaluation_tree_from_csv
              controller.send :confirm_or_update
            end

            it "should remove round robin evaluations" do
              # REMOVING evaluations:
              #
              # ueno -> ueno
              #         -> ueyonabaru
              #         -> urasaki
              # ueyonabaru   -> ueno
              #         -> ueyonabaru
              #         -> urasaki
              # urasaki   -> ueno
              #         -> ueyonabaru
              #         -> urasaki
              users = ["ueno", "ueyonabaru", "urasaki"]
              object_users = ["ueno", "ueyonabaru", "urasaki"]
              users.each do |login|
                evaluations = Evaluation.find_all_by_user_id(User.find_by_login(login))
                evaluations.collect { |e| e.object_user.login }.should_not include(*object_users)
              end
            end

            it "should keep evaluations to the head" do
              # Keeping evaluations:
              #
              # ueno -> ueunten
              # ueyonabaru   -> ueunten
              evaluations = collect_evaluations_match_user_and_object_user(@evaluations_before_change, ["ueno", "ueyonabaru"], ["ueunten"])
              evaluations.each do |evaluation|
                Evaluation.exists?(evaluation).should be_true
              end
            end
          end

          describe "when the destination group becomes having number of children more than 2" do
            before :each do
              controller.class.stub(:build_yaml_buffer) {
                <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    group1:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
  #{user_evaluation_tree_id "urasaki"}:
EOS
              }
              controller.send :build_evaluation_tree_from_csv
              controller.send :confirm_or_update

              @evaluations_before_change = Evaluation.all

              controller.class.stub(:build_yaml_buffer) {
                <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    #{@klass.no_user_assigned_only.first.id}:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
EOS
              }
              controller.send :build_evaluation_tree_from_csv
              controller.send :confirm_or_update
            end

            it "should generate expected evaluations" do
              # Expected evaluations:
              #
              # ueno -> ueunten
              #         -> ueno
              #         -> ueyonabaru
              #         -> urasaki
              # ueyonabaru   -> ueunten
              #         -> ueno
              #         -> ueyonabaru
              #         -> urasaki
              # urasaki   -> ueunten
              #         -> ueno
              #         -> ueyonabaru
              #         -> urasaki
              # ueunten  -> ueunten
              users = ["ueno", "ueyonabaru", "urasaki"]
              object_users = ["ueunten", "ueno", "ueyonabaru", "urasaki"]
              users.each do |login|
                evaluations = Evaluation.find_all_by_user_id(User.find_by_login(login))
                evaluations.collect { |e| e.object_user.login }.should include(*object_users)
              end
              users = ["ueunten"]
              object_users = ["ueunten"]
              users.each do |login|
                evaluations = Evaluation.find_all_by_user_id(User.find_by_login(login))
                evaluations.collect { |e| e.object_user.login }.should include(*object_users)
              end
            end

            it "should keep evaluations originally exist in the group" do
              evaluations = collect_evaluations_match_user_and_object_user(@evaluations_before_change, ["ueyonabaru", "ueno"], ["ueunten"])
              evaluations.each do |evaluation|
                Evaluation.exists?(evaluation).should be_true
              end
            end
          end

          describe "when the destination is under the same head" do
            before :each do
              controller.class.stub(:build_yaml_buffer) {
                <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    group1:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
    #{user_evaluation_tree_id "urasaki"}:
EOS
              }
              controller.send :build_evaluation_tree_from_csv
              controller.send :confirm_or_update

              @evaluations_before_change = Evaluation.all

              controller.class.stub(:build_yaml_buffer) {
                <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    #{@klass.no_user_assigned_only.first.id}:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
EOS
              }
              controller.send :build_evaluation_tree_from_csv
              controller.send :confirm_or_update
            end

            it "should keep evaluations to the head" do
              evaluations = collect_evaluations_match_user_and_object_user(@evaluations_before_change, ["ueunten", "ueno", "ueyonabaru"], ["ueunten"])
              evaluations.each do |evaluation|
                Evaluation.exists?(evaluation).should be_true
              end
            end
          end

        end

        describe "when children removed" do
          before :each do
            # The original evaluation tree is below.
            #
            # |\- iwamichi
            # |    |
            # |     \- ueunten
            # |    |
            # |     \- ueno
            # |    |
            # |     \- ueyonabaru
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
  #{user_evaluation_tree_id "ueno"}:
  #{user_evaluation_tree_id "ueyonabaru"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
          end

          it "should remove all evaluations to the parent when number of children less than 2" do
            evaluations = Evaluation.find_all_by_object_user_id(User.find_by_login("iwamichi"))

            # |\- iwamichi
            # |    |
            # |     \- ueunten
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
            evaluations.each do |e|
              Evaluation.exists?(e).should be_false
            end
          end

          it "should keep evaluations to the parent when number of children more than 1" do
            evaluations = Evaluation.find_all_by_object_user_id(User.find_by_login("iwamichi"))
            # |\- iwamichi
            # |    |
            # |     \- ueunten
            # |    |
            # |     \- ueno
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
  #{user_evaluation_tree_id "ueno"}:
EOS
            }

          end
        end

        describe "when group removed" do
          before :each do
            # Before modification
            #
            # |\- iwamichi
            # |    |
            # |     \- ueunten
            # |         |
            # |          \- group1
            # |              |
            # |               \- ueno
            # |              |
            # |               \- ueyonabaru
            # |              |
            # |               \- urasaki
            #
            # After modification
            #
            # |\- iwamichi
            # |    |
            # |     \- ueunten
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    group1:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update

            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
          end

          it "constructs expected evaluation tree structure" do
            evaluation_trees = EvaluationTree::Multifaceted.selected_only
            evaluation_trees.count.should be(2)
            evaluation_trees.collect { |e| e.user.login }.should include("iwamichi")
            evaluation_trees.collect { |e| e.user.login }.should include("ueunten")
            EvaluationTree::Multifaceted.find_by_user_login("ueunten").parent.should == EvaluationTree::Multifaceted.find_by_user_login("iwamichi")
          end

          it "generates expected evaluations" do
            Evaluation.count.should be_zero
          end

          it "should remove EvaluationTree for group" do
            EvaluationTree.no_user_assigned_only.count.should be_zero
          end

          it "should not remove EvaluationTree for User" do
            EvaluationTree.find_by_user_login("ueno").should_not be_nil
            EvaluationTree.find_by_user_login("ueyonabaru").should_not be_nil
            EvaluationTree.find_by_user_login("urasaki").should_not be_nil
          end
        end

        describe "when folded group removed" do
          it "remove the group and its all children passed by params" do
            # already established, no example needed.
          end
        end

        describe "when the top of sub tree moved to root" do
          before :each do
            # The original evaluation tree is below.
            #
            # \- iwamichi
            #     |
            #     |\- ueunten
            #     |    |
            #     |     \- ueno
            #     |    |
            #     |     \- ueyonabaru
            #     |    |
            #     |     \- urasaki
            #     |
            #      \- ushiduka
            #
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    #{user_evaluation_tree_id "ueno"}:
    #{user_evaluation_tree_id "ueyonabaru"}:
    #{user_evaluation_tree_id "urasaki"}:
  #{user_evaluation_tree_id "ushiduka"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update

          end

          it "should keep evaluations of children" do
            evaluations = ["ueno", "ueyonabaru", "urasaki"].inject([]) do |evaluations, login|
              evals = Evaluation.find_all_by_user_id(User.find_by_login(login))
              evals.count.should equal(1)
              evals.first.object_user.login.should == "ueunten"
              evaluations.concat evals
            end

            # After modification
            #
            # |\- iwamichi
            # |    |
            # |     \- ushiduka
            # |
            #  \- ueunten
            #      |
            #       \- ueno
            #      |
            #       \- ueyonabaru
            #      |
            #       \- urasaki
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ushiduka"}:
#{user_evaluation_tree_id "ueunten"}:
  #{user_evaluation_tree_id "ueno"}:
  #{user_evaluation_tree_id "ueyonabaru"}:
  #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update

            # should -> ueunten
            # ueyonabaru  -> ueunten
            # urasaki  -> ueunten
            evaluations.each do |e|
              Evaluation.exists?(e)
            end
          end

          it "should remove evaluation to original parent" do
            # Below evaluation exists at this point.
            #
            # ueunten -> iwamichi
            evaluations = Evaluation.find_all_by_user_id(User.find_by_login("ueunten"))
            evaluations.collect { |e| e.object_user.login }.should include("iwamichi")
            evaluations = Evaluation.find_all_by_user_id(User.find_by_login("ushiduka"))
            evaluations.collect { |e| e.object_user.login }.should include("iwamichi")

            # After modification
            #
            # |\- iwamichi
            # |    |
            # |     \- ushiduka
            # |
            #  \- ueunten
            #      |
            #       \- ueno
            #      |
            #       \- ueyonabaru
            #      |
            #       \- urasaki
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ushiduka"}:
#{user_evaluation_tree_id "ueunten"}:
  #{user_evaluation_tree_id "ueno"}:
  #{user_evaluation_tree_id "ueyonabaru"}:
  #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update

            # ueunten -> iwamichi [removed]
            evaluations = Evaluation.find_all_by_user_id(User.find_by_login("ueunten"))
            evaluations.collect { |e| e.object_user.login }.should_not include("iwamichi")
            # ushiduka -> iwamichi [removed]
            evaluations = Evaluation.find_all_by_user_id(User.find_by_login("ushiduka"))
            evaluations.collect { |e| e.object_user.login }.should_not include("iwamichi")
          end
        end

        describe "when the top of sub tree moved to root is folded" do
          before :each do
            # The original evaluation tree is below.
            #
            # \- iwamichi
            #     |
            #     |\- ueunten
            #     |    |
            #     |     \- ueno
            #     |    |
            #     |     \- ueyonabaru
            #     |    |
            #     |     \- urasaki
            #     |
            #      \- ushiduka
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    #{user_evaluation_tree_id "ueno"}:
    #{user_evaluation_tree_id "ueyonabaru"}:
    #{user_evaluation_tree_id "urasaki"}:
  #{user_evaluation_tree_id "ushiduka"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
          end

          it "should keep evaluations of children" do
            evaluations = Evaluation.find_all_by_object_user_id(User.find_by_login("ueunten"))
            # |\- iwamichi
            # |    |
            # |     \- ushiduka
            # |
            #  \- ueunten [folded]
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ushiduka"}:
#{user_evaluation_tree_id "ueunten"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.params.delete :deleted_evaluation_trees
            controller.send :confirm_or_update
            evaluations.each do |e|
              Evaluation.exists?(e).should be_true
            end
          end

          it "should remove evaluation to original parent" do
            evaluations = Evaluation.find_all_by_object_user_id(User.find_by_login("iwamichi"))
            # |\- iwamichi
            # |    |
            # |     \- ushiduka
            # |
            #  \- ueunten [folded]
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ushiduka"}:
#{user_evaluation_tree_id "ueunten"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.params.delete :deleted_evaluation_trees
            controller.send :confirm_or_update
            evaluations.each do |e|
              Evaluation.exists?(e).should be_false
            end
          end
        end

        describe "when the top of sub tree moved to another parent" do
          before :each do
            # Before modification
            #
            # \- iwamichi
            #     |
            #     |\- ueunten
            #     |    |
            #     |     \- ueno
            #     |    |
            #     |     \- ueyonabaru
            #     |    |
            #     |     \- urasaki
            #     |
            #      \- ushiduka
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    #{user_evaluation_tree_id "ueno"}:
    #{user_evaluation_tree_id "ueyonabaru"}:
    #{user_evaluation_tree_id "urasaki"}:
  #{user_evaluation_tree_id "ushiduka"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
          end

          it "should keep evaluations of children" do
            evaluations = Evaluation.find_all_by_object_user_id(User.find_by_login("ueunten"))
            # \- iwamichi
            #     |
            #      \- ushiduka
            #          |
            #           \- ueunten
            #               |
            #                \- ueno
            #               |
            #                \- ueyonabaru
            #               |
            #                \- urasaki
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ushiduka"}:
    #{user_evaluation_tree_id "ueunten"}:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
            evaluations.each do |e|
              Evaluation.exists?(e).should be_true
            end
          end

          it "should remove evaluation to original parent" do
            # \- iwamichi
            #     |
            #      \- ushiduka
            #          |
            #           \- ueunten
            #               |
            #                \- ueno
            #               |
            #                \- ueyonabaru
            #               |
            #                \- urasaki
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ushiduka"}:
    #{user_evaluation_tree_id "ueunten"}:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
            Evaluation.find_all_by_object_user_id(User.find_by_login("iwamichi")).should be_empty
          end
        end

        describe "when the top of sub tree moved to another parent is folded" do
          before :each do
            # Before modification
            #
            # \- iwamichi
            #     |
            #     |\- ueunten
            #     |    |
            #     |     \- ueno
            #     |    |
            #     |     \- ueyonabaru
            #     |    |
            #     |     \- urasaki
            #     |
            #      \- ushiduka
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    #{user_evaluation_tree_id "ueno"}:
    #{user_evaluation_tree_id "ueyonabaru"}:
    #{user_evaluation_tree_id "urasaki"}:
  #{user_evaluation_tree_id "ushiduka"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
          end

          it "should keep evaluations of children" do
            evaluations = Evaluation.find_all_by_object_user_id(User.find_by_login("ueunten"))
            # \- iwamichi
            #     |
            #      \- ushiduka
            #          |
            #           \- ueunten [folded]
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ushiduka"}:
    #{user_evaluation_tree_id "ueunten"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.params.delete :deleted_evaluation_trees
            controller.send :confirm_or_update
            evaluations.each do |e|
              Evaluation.exists?(e).should be_true
            end
          end

          it "should remove evaluation to original parent" do
            # \- iwamichi
            #     |
            #      \- ushiduka
            #          |
            #           \- ueunten [folded]
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ushiduka"}:
    #{user_evaluation_tree_id "ueunten"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.params.delete :deleted_evaluation_trees
            controller.send :confirm_or_update
            Evaluation.find_all_by_object_user_id(User.find_by_login("iwamichi")).should be_empty
          end
        end

        describe "when group moved to root" do
          before :each do
            # Before modification
            #
            # |\- iwamichi
            # |    |
            # |     \- ueunten
            # |         |
            # |          \- group1
            # |              |
            # |               \- ueno
            # |              |
            # |               \- ueyonabaru
            # |              |
            # |               \- urasaki
            #
            # After modification
            #
            # |\- iwamichi
            # |    |
            # |     \- ueunten
            # |
            # |\- group1
            # |    |
            # |     \- ueno
            # |    |
            # |     \- ueyonabaru
            # |    |
            # |     \- urasaki
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    group1:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update

            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
#{@klass.no_user_assigned_only.first.id}:
  #{user_evaluation_tree_id "ueno"}:
  #{user_evaluation_tree_id "ueyonabaru"}:
  #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
          end

          it "constructs expected evaluation tree structure" do
            evaluation_trees = EvaluationTree::Multifaceted.selected_only
            evaluation_trees.count.should be(6)
            user_evaluation_tree("iwamichi").root?.should be_true
            user_evaluation_tree("ueunten").parent.should == user_evaluation_tree("iwamichi")
            group = @klass.no_user_assigned_only.first
            group.root?.should be_true
            user_evaluation_tree("ueno").parent.should == group
            user_evaluation_tree("ueyonabaru").parent.should == group
            user_evaluation_tree("urasaki").parent.should == group
          end

          it "should remove evaluations which is to parent" do
            Evaluation.find_all_by_object_user_id(User.find_by_login("iwamichi")).should be_empty
            Evaluation.find_all_by_object_user_id(User.find_by_login("ueunten")).should be_empty
          end

          it "generates expected number of evaluations" do
            Evaluation.count.should equal(9)
          end

          it "generates round robin evaluations" do
            # ueno -> ueno
            #         -> ueyonabaru
            #         -> urasaki
            # ueyonabaru   -> ueno
            #         -> ueyonabaru
            #         -> urasaki
            # urasaki   -> ueno
            #         -> ueyonabaru
            #         -> urasaki
            users = ["ueno", "ueyonabaru", "urasaki"]
            users.each do |user|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(user))
              evaluations.count.should equal(users.count)
              evaluations.collect { |e| e.object_user.login }.should include(*users)
            end
          end
        end

        describe "when group moved to root is folded" do
          before :each do
            # Before modification
            #
            # \- iwamichi
            #     |
            #      \- ueunten
            #          |
            #           \- group1
            #               |
            #                \- ueno
            #               |
            #                \- ueyonabaru
            #               |
            #                \- urasaki
            #
            # After modification
            #
            # \- iwamichi
            # |   |
            # |    \- ueunten
            # |
            #  \- group1 [folded]
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    group1:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update

            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
#{@klass.no_user_assigned_only.first.id}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.params.delete :deleted_evaluation_trees
            controller.send :confirm_or_update
          end

          it "generates expected evaluations" do
            # ueno -> ueno
            #         -> ueyonabaru
            #         -> urasaki
            # ueyonabaru   -> ueno
            #         -> ueyonabaru
            #         -> urasaki
            # urasaki   -> ueno
            #         -> ueyonabaru
            #         -> urasaki
            Evaluation.count.should equal(9)
            users = object_users = ["ueno", "ueyonabaru", "urasaki"]
            users.each do |user|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(user))
              evaluations.collect { |e| e.object_user.login }.should include(*object_users)
            end
          end
        end

        describe "when group moved to child of another parent" do
          before :each do
            # Before modification
            #
            # \- iwamichi
            #     |
            #     |\- ueunten
            #     |    |
            #     |     \- group1
            #     |         |
            #     |          \- ueno
            #     |         |
            #     |          \- ueyonabaru
            #     |         |
            #     |          \- urasaki
            #     |
            #      \- ushiduka
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    group1:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
  #{user_evaluation_tree_id "ushiduka"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update

            # After modification
            #
            # \- iwamichi
            #     |
            #     |\- ueunten
            #     |
            #      \- ushiduka
            #          |
            #           \- group1
            #               |
            #                \- ueno
            #               |
            #                \- ueyonabaru
            #               |
            #                \- urasaki
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
  #{user_evaluation_tree_id "ushiduka"}:
    #{@klass.no_user_assigned_only.first.id}:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
          end

          it "generates expected evaluations" do
            # ueno  -> ueno
            #          -> ueyonabaru
            #          -> urasaki
            #          -> ushiduka
            # ueyonabaru    -> ueno
            #          -> ueyonabaru
            #          -> urasaki
            #          -> ushiduka
            # urasaki    -> ueno
            #          -> ueyonabaru
            #          -> urasaki
            #          -> ushiduka
            # ueunten   -> iwamichi
            # ushiduka -> iwamichi
            #          -> ushiduka
            # iwamichi  -> iwamichi
            Evaluation.count.should equal(16)
            users = ["ueno", "ueyonabaru", "urasaki"]
            object_users = ["ueno", "ueyonabaru", "urasaki", "ushiduka"]
            users.each do |user|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(user))
              evaluations.collect { |e| e.object_user.login }.should include(*object_users)
            end
            users = ["ueunten"]
            object_users = ["iwamichi"]
            users.each do |user|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(user))
              evaluations.collect { |e| e.object_user.login }.should include(*object_users)
            end
            users = ["iwamichi"]
            object_users = ["iwamichi"]
            users.each do |user|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(user))
              evaluations.collect { |e| e.object_user.login }.should include(*object_users)
            end
            users = ["ushiduka"]
            object_users = ["iwamichi", "ushiduka"]
            users.each do |user|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(user))
              evaluations.collect { |e| e.object_user.login }.should include(*object_users)
            end
          end
        end

        describe "when group moved to child of another parent is folded" do
          before :each do
            # Before modification
            #
            # \- iwamichi
            # |   |
            # |    \- ueunten
            # |        |
            # |         \- group1
            # |             |
            # |              \- ueno
            # |             |
            # |              \- ueyonabaru
            # |             |
            # |              \- urasaki
            # |
            #  \- ushiduka
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    group1:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
#{user_evaluation_tree_id "ushiduka"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update

            @evaluations = User.find_by_login("ueno").passive_evaluations
            @evaluations.concat(User.find_by_login("ueyonabaru").passive_evaluations)
            @evaluations.concat(User.find_by_login("urasaki").passive_evaluations)

            # After modification
            #
            # \- iwamichi
            # |   |
            # |    \- ueunten
            # |
            #  \- ushiduka
            #      |
            #       \- group1
            #           |
            #            \- ueno
            #           |
            #            \- ueyonabaru
            #           |
            #            \- urasaki
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
#{user_evaluation_tree_id "ushiduka"}:
  #{@klass.no_user_assigned_only.first.id}:
    #{user_evaluation_tree_id "ueno"}:
    #{user_evaluation_tree_id "ueyonabaru"}:
    #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
          end

          it "generates expected evaluations" do
            # ueno  -> ueno
            #          -> ueyonabaru
            #          -> urasaki
            #          -> ushiduka
            # ueyonabaru    -> ueno
            #          -> ueyonabaru
            #          -> urasaki
            #          -> ushiduka
            # urasaki    -> ueno
            #          -> ueyonabaru
            #          -> urasaki
            #          -> ushiduka
            # ushiduka -> ushiduka
            Evaluation.count.should equal(13)
            users = ["ueno", "ueyonabaru", "urasaki"]
            object_users = ["ueno", "ueyonabaru", "urasaki", "ushiduka"]
            users.each do |user|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(user))
              evaluations.collect { |e| e.object_user.login }.should include(*object_users)
            end
            users = ["ushiduka"]
            object_users = ["ushiduka"]
            users.each do |user|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(user))
              evaluations.collect { |e| e.object_user.login }.should include(*object_users)
            end
          end

          it "keeps round robin evaluations" do
            pending
            @evaluations.each do |evaluation|
              Evaluation.exists?(evaluation).should be_true
            end
          end
        end

        describe "with no group" do
          before :each do
            # |\- iwamichi
            # |    |
            # |    \- ushiduka
            # |
            # |\- ueunten
            # |    |
            # |     \- ueno
            # |    |
            # |     \- ueyonabaru
            # |    |
            # |     \- urasaki
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ushiduka"}:
#{user_evaluation_tree_id "ueunten"}:
  #{user_evaluation_tree_id "ueno"}:
  #{user_evaluation_tree_id "ueyonabaru"}:
  #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
          end

          it "should generate the unidirectional evaluations to the top has children more than 1" do
            # Expected evaluations:
            #
            # ueno -> ueunten
            # ueyonabaru ->   ueunten
            # urasaki ->   ueunten
            # ueunten ->  ueunten
            Evaluation.count.should equal(4)
            users = ["ueno", "ueyonabaru", "urasaki", "ueunten"]
            object_users = ["ueunten"]
            users.each do |user|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(user))
              evaluations.collect { |e| e.object_user.login }.should include(*object_users)
            end
          end

          it "should not generate the unidirectional evaluations to the top has children less than 2" do
            Evaluation.find_all_by_user_id(User.find_by_login("ushiduka")).should be_empty
          end

          it "should generate self-evaluation when an evaluatee have number of passive evaluations more than 1" do
            User.find_by_login("ueunten").has_self_evaluation?.should be_true
          end

          it "should not generate self-evaluation when an evaluatee have number of passive evaluations less than 2" do
            User.find_by_login("iwamichi").has_self_evaluation?.should be_false
          end

          it "does not generates round robin evaluations" do
            # already established
          end

          it "should set true to selected-column of activated EvaluationTrees" do
            users = ["iwamichi", "ushiduka", "ueunten", "ueno", "ueyonabaru", "urasaki"]
            evaluation_trees = users.collect { |u| user_evaluation_tree(u) }
            evaluation_trees.each { |e| e.selected.should be_true }
            @klass.find(:all, :conditions => ["not evaluation_trees.id in(?)", evaluation_trees]).each do |e|
              e.selected.should be_false
            end
          end
        end

        describe "with group" do
          before :each do
            # |\- iwamichi
            # |    |
            # |     \- ueunten
            # |         |
            # |          \- group
            # |              |
            # |               \- ueno
            # |              |
            # |               \- ueyonabaru
            # |              |
            # |               \- urasaki
            @original_evaluation_trees = EvaluationTree.all
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    group1:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
      #{user_evaluation_tree_id "urasaki"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
          end

          it "should create an EvaluationTree as a new group" do
            groups = EvaluationTree.no_user_assigned_only
            groups.count.should be(1)
            @original_evaluation_trees.should_not include(*groups)
          end

          it "generates expected evaluations" do
            # ueno -> ueno
            #         -> ueyonabaru
            #         -> urasaki
            #         -> ueunten
            # ueyonabaru   -> ueno
            #         -> ueyonabaru
            #         -> urasaki
            #         -> ueunten
            # urasaki   -> ueno
            #         -> ueyonabaru
            #         -> urasaki
            #         -> ueunten
            # ueunten  -> ueunten
            Evaluation.count.should be(13)
            users = ["ueno", "ueyonabaru", "urasaki"]
            object_users = ["ueno", "ueyonabaru", "urasaki", "ueunten"]
            users.each do |user|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(user))
              evaluations.collect { |e| e.object_user.login }.should include(*object_users)
            end
            users = ["ueunten"]
            object_users = ["ueunten"]
            users.each do |user|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(user))
              evaluations.collect { |e| e.object_user.login }.should include(*object_users)
            end
          end

          it "should set true to selected-column of activated EvaluationTrees" do
            users = ["iwamichi", "ueunten", "ueno", "ueyonabaru", "urasaki"]
            evaluation_trees = users.collect { |u| user_evaluation_tree(u) }
            evaluation_trees << EvaluationTree.no_user_assigned_only.first
            evaluation_trees.each { |e| e.selected.should be_true }
            @klass.find(:all, :conditions => ["not evaluation_trees.id in(?)", evaluation_trees]).each do |e|
              e.selected.should be_false
            end
          end
        end

        describe "with group has evaluatees less than 3" do
          before :each do
            # |\- iwamichi
            # |    |
            # |     \- ueunten
            # |         |
            # |          \- group
            # |              |
            # |               \- ueno
            # |              |
            # |               \- ueyonabaru
            controller.class.stub(:build_yaml_buffer) {
              <<-EOS
#{user_evaluation_tree_id "iwamichi"}:
  #{user_evaluation_tree_id "ueunten"}:
    group1:
      #{user_evaluation_tree_id "ueno"}:
      #{user_evaluation_tree_id "ueyonabaru"}:
EOS
            }
            controller.send :build_evaluation_tree_from_csv
            controller.send :confirm_or_update
          end

          it "generates expected evaluations" do
            # ueno -> ueunten
            # ueyonabaru   -> ueunten
            # ueunten  -> ueunten
            Evaluation.count.should equal(3)
            ["ueno", "ueyonabaru", "ueunten"].each do |user|
              evaluations = Evaluation.find_all_by_user_id(User.find_by_login(user))
              evaluations.count.should equal(1)
              evaluations.first.object_user.login.should == "ueunten"
            end
          end
        end
      end
    end
  end

  describe "#build_evaluation_tree_from_csv" do
    describe "when csv file is valid" do
      before :each do
        @klass = EvaluationTree::TopDown
        @tempfile = Tempfile.open("build_evaluation_tree_from_csv") do |io|
          # |\- iwamichi
          # |    \
          # |     \- ueunten
          # |         \
          # |          \- ueno
          io << <<-EOS
評価組システムID,評価フラグ(FALSE=未評価),対象外フラグ(TRUE=対象外),社員ID,社員名,所属部課,役職,職種,備考,ログイン名
#{user_evaluation_tree_id "iwamichi"},,,333,岩道光,役員(営業戦略部),常務取締役,管理職,,iwamichi
#{user_evaluation_tree_id "ueunten"},,,588,上運天嘉則,営業戦略部技術支援課,部長,管理職,,,ueunten
#{user_evaluation_tree_id "ueno"},,,7218,上之屋克洋,営業戦略部技術支援課,ﾘｰﾀﾞ,営業戦略技術支援,,,,ueno
EOS
        end
        controller.params[:file] = @tempfile
        @klass = EvaluationTree::TopDown
        controller.instance_eval("@klass = #{@klass}")
      end

      it "should set json as evaluation tree" do
        controller.send(:build_evaluation_tree_from_csv)
        controller.params[:evaluation_trees].should == "[[#{user_evaluation_tree_id "iwamichi"},[[#{user_evaluation_tree_id "ueunten"},[[#{user_evaluation_tree_id "ueno"},[]]]]]]]"
      end

      it "should set array of deleting nodes" do
        deleting_evaluation_trees = [mock_model(@klass, :id=>1),
                                     mock_model(@klass, :id=>2),
                                     mock_model(@klass, :id=>3)]
        @klass.stub(:find) { deleting_evaluation_trees }
        controller.send(:build_evaluation_tree_from_csv)
        controller.params[:deleted_evaluation_trees].should == "[1,2,3]"
      end
    end
  end

  def user_evaluation_tree(user_login)
    @klass.find_by_user_login(user_login)
  end

  def user_evaluation_tree_id(user_login)
    user_evaluation_tree(user_login).id
  end

  def collect_evaluations_match_user_and_object_user(evaluations, user_logins, object_user_logins)
    user_logins.collect { |user_login|
      object_user_logins.collect do |object_user_login|
        evaluations.select do |evaluation|
          evaluation.user.login == user_login and evaluation.object_user.login == object_user_login
        end
      end
    }.flatten.compact
  end
end
