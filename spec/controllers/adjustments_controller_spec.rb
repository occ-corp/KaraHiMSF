require 'spec_helper'

describe AdjustmentsController do

  def mock_adjustment(stubs={})
    (@mock_adjustment ||= mock_model(Adjustment).as_null_object).tap do |adjustment|
      adjustment.stub(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={ })
    (@mock_user ||= mock_model(User).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def current_user(stubs={ })
    (@current_user ||= mock_model(User).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def mock_evaluation_tree(stubs={ })
    (@mock_evaluation_tree ||= mock_model(EvaluationTree).as_null_object).tap do |evaluation_tree|
      evaluation_tree.stub(stubs) unless stubs.empty?
    end
  end

  def mock_role(stubs={ })
    (@mock_role ||= mock_model(EvaluationTree).as_null_object).tap do |role|
      role.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET show" do
    before :each do
      @mock_roles = [mock_role]
      @mock_roles.stub(:admin?) { true }
      @mock_users = [mock_user(:total => 0)]
    end

    it "assigns users as @users" do
      @controller.stub(:current_user) { current_user(:roles => @mock_roles) }
      User.stub(:aggregate_each_user) { @mock_users }
      @mock_users.stub(:paginate) { @mock_users }
      User.stub(:scoped_by_phrase) { @mock_users }
      get :show
      assigns(:users).should == @mock_users
    end

    it "should call User.aggregate_each_user with no arguments when current_user is an admin" do
      @controller.stub(:current_user) { current_user(:roles => @mock_roles) }
      User.should_receive(:aggregate_each_user).with(no_args) { @mock_users }
      @mock_users.stub(:paginate) { @mock_users }
      User.stub(:scoped_by_phrase) { @mock_users }
      get :show
    end

    it "should call User.aggregate_each_user with users under the current_user's evaluation tree when current_user is a decider" do
      @mock_roles.stub(:admin?) { false }
      @mock_roles.stub(:decider?) { true }
      mock_evaluation_trees = [mock_evaluation_tree]
      mock_evaluation_trees.stub(:topdown_only) { mock_evaluation_trees }
      @controller.stub(:current_user) {current_user(:roles => @mock_roles, :evaluation_trees => mock_evaluation_trees)}
      User.stub(:under_evaluation_tree).with(mock_evaluation_tree) { @mock_users }
      User.should_receive(:aggregate_each_user).with(mock_user) { @mock_users }
      @mock_users.stub(:paginate) { @mock_users }
      User.stub(:scoped_by_phrase) { @mock_users }
      get :show
    end
  end

  describe "PUT update" do
    before :each do
      @controller.stub(:current_user) { current_user }
    end

    describe "with valid params" do
      it "updates the requested adjustments" do
        Adjustment.should_receive(:find).with("27") { mock_adjustment }
        mock_adjustment.should_receive(:update_attributes!).with({"user_id" => "1", "adjustment" => "-0.8", "id" => "27"})
        Adjustment.should_receive(:create!).with({"user_id" => "2", "adjustment" => "0"})
        put :update, :adjustments => {
          "1" => { "user_id" => "1", "adjustment" => "-0.8", "id" => "27" },
          "2" => { "user_id" => "2", "adjustment" => "0" }
        }
      end

      it "redirects to the adjustment" do
        mock_adjustment.stub(:update_attributes!)
        Adjustment.stub(:find) { mock_adjustment(:update_attributes => true) }
        Adjustment.stub(:create!)
        put :update, :adjustments => {
          "1" => { "user_id" => "1", "adjustment" => "-0.8" },
        }
        response.should redirect_to(adjustment_url)
      end
    end

    describe "with invalid params" do
      before :each do
        evaluation_trees = [mock_evaluation_tree]
        evaluation_trees.stub(:topdown_only) { evaluation_trees }
        current_user.stub(:evaluation_trees) { evaluation_trees }
        controller.stub(:current_user) { current_user }
        adjustments = [mock_adjustment]
        @users = [mock_user]
        User.stub(:under_evaluation_tree).with(mock_evaluation_tree) { @users }
      end

      it "assigns users under the evaluation tree as @users" do
        Adjustment.stub(:create!) { raise ActiveRecord::ActiveRecordError }
        put :update, :adjustments => {
          "1" => { "user_id" => "1", "adjustment" => "-0.8" },
        }
        assigns(:users).should == @users
      end

      it "re-renders the 'show' template" do
        Adjustment.stub(:create!) { raise ActiveRecord::ActiveRecordError }
        put :update, :adjustments => {
          "1" => { "user_id" => "1", "adjustment" => "-0.8" },
        }
        response.should render_template("show")
      end
    end

  end

end
