require 'spec_helper'

describe InterviewsController do

  def mock_interview(stubs={ })
    (@interview ||= mock_model(Interview).as_null_object).tap do |interview|
      interview.stub(stubs) unless stubs.empty?
    end
  end

  def mock_role(stubs={ })
    (@role ||= mock_model(Role).as_null_object).tap do |role|
      role.stub(stubs) unless stubs.empty?
    end
  end

  def mock_roles(stubs={ })
    (@mock_roles ||= [mock_role]).tap do |roles|
      roles.stub(stubs) unless stubs.empty?
    end
  end

  def mock_current_user(stubs={ })
    (@current_user ||= mock_model(User).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def mock_evaluation_tree(stubs={ })
    (@evaluation_tree ||= mock_model(EvaluationTree).as_null_object).tap do |evaluation_tree|
      evaluation_tree.stub(stubs) unless stubs.empty?
    end
  end

  def mock_evaluation_trees(stubs={ })
    (@mock_evaluation_trees ||= [mock_evaluation_tree]).tap do |evaluation_trees|
      evaluation_trees.stub(stubs) unless stubs.empty?
    end
  end

  before :each do
    controller.stub(:current_user) { mock_current_user }
  end

  describe "GET 'index'" do
    before :each do
      @users = User.all
      @users.stub(:scoped_by_phrase) { @users }
      @users.stub(:paginate) { @users }
    end

    describe "when current_user is admin" do
      it "assigns the results of User.under_evaluation_tree as @object_users" do
        mock_current_user(:roles => mock_roles(:admin? => true))
        User.stub(:all_evaluatees) { @users }
        get :index
        assigns(:object_users).should == @users
      end
    end

    describe "when current_user is not admin" do
      it "assigns the results of User.under_evaluation_tree as @object_users" do
        mock_current_user(:roles => mock_roles(:admin? => false), :evaluation_trees => mock_evaluation_trees(:topdown_only => mock_evaluation_trees))
        User.should_receive(:under_evaluation_tree).with(mock_evaluation_tree) { @users }
        get :index
        assigns(:object_users).should == @users
      end
    end

    describe "uninterviewed_only" do
      it "assigns the pending object_users as @object_users when no passed" do
        mock_current_user(:roles => mock_roles(:admin? => true))
        @users.should_not_receive(:uninterviewed) { @users }
        get :index
      end

      it "assigns the pending object_users as @object_users when true passed" do
        mock_current_user(:roles => mock_roles(:admin? => true))
        User.stub(:all_evaluatees) { @users }
        @users.should_receive(:uninterviewed) { @users }
        get :index, :uninterviewed_only => true
      end
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created interview as @interview" do
        Interview.stub(:new).with({'these' => 'params'}) { mock_interview(:save => true) }
        post :create, :interview => {'these' => 'params'}
        assigns(:interview).should be(mock_interview)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved interview as @interview" do
        Interview.stub(:new).with({'these' => 'params'}) { mock_interview(:save => false) }
        post :create, :interview => {'these' => 'params'}
        assigns(:interview).should be(mock_interview)
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested interview" do
        Interview.should_receive(:find).with("37") { mock_interview }
        mock_interview.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :interview => {'these' => 'params'}
      end

      it "assigns the requested interview as @interview" do
        Interview.stub(:find) { mock_interview(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:interview).should be(mock_interview)
      end
    end

    describe "with invalid params" do
      it "assigns the interview as @interview" do
        Interview.stub(:find) { mock_interview(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:interview).should be(mock_interview)
      end
    end
  end

end
