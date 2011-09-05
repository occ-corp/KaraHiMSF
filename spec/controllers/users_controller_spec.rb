# -*- coding: utf-8 -*-
require 'spec_helper'
require 'spec_authentication_helper'

describe UsersController do

  # def mock_user(stubs={})
  #   @mock_user ||= mock_model(User, stubs).as_null_object
  # end

  include SpecAuthenticationHelper

  def mock_current_user(stubs={ })
    (@current_user ||= mock_model(User).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def mock_role(stubs={ })
    (@role ||= mock_model(Role).as_null_object).tap do |role|
      role.stub(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={ })
    (@user ||= mock_model(User).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def mock_evaluation_tree(stubs={ })
    (@evaluation_tree ||= mock_model(EvaluationTree).as_null_object).tap do |evaluation_tree|
      evaluation_tree.stub(stubs) unless stubs.empty?
    end
  end

  def mock_evaluation_item_map
    { }
  end

  describe "GET index" do
    it "assigns all users as @users" do
      pending
      User.stub(:all) { [mock_user] }
      get :index
      assigns(:users).should eq([mock_user])
    end
  end

  describe "GET show" do
    it "assigns the requested user as @user" do
      pending
      User.stub(:find).with("37") { mock_user }
      get :show, :id => "37"
      assigns(:user).should be(mock_user)
    end
  end

  describe "GET new" do
    it "assigns a new user as @user" do
      User.stub(:new) { mock_user }
      get :new
      assigns(:user).should be(mock_user)
    end
  end

  describe "GET edit" do
    it "assigns the requested user as @user" do
      pending
      User.stub(:find).with("37") { mock_user }
      get :edit, :id => "37"
      assigns(:user).should be(mock_user)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created user as @user" do
        User.stub(:new).with({'these' => 'params'}) { mock_user(:save => true) }
        post :create, :user => {'these' => 'params'}
        assigns(:user).should be(mock_user)
      end

      it "redirects to the created user" do
        pending
        User.stub(:new) { mock_user(:save => true) }
        post :create, :user => {}
        response.should redirect_to(user_url(mock_user))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user" do
        User.stub(:new).with({'these' => 'params'}) { mock_user(:save => false) }
        post :create, :user => {'these' => 'params'}
        assigns(:user).should be(mock_user)
      end

      it "re-renders the 'new' template" do
        pending
        User.stub(:new) { mock_user(:save => false) }
        post :create, :user => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested user" do
        pending
        User.should_receive(:find).with("37") { mock_user }
        mock_user.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :user => {'these' => 'params'}
      end

      it "assigns the requested user as @user" do
        pending
        User.stub(:find) { mock_user(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:user).should be(mock_user)
      end

      it "redirects to the user" do
        pending
        User.stub(:find) { mock_user(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(user_url(mock_user))
      end
    end

    describe "with invalid params" do
      it "assigns the user as @user" do
        pending
        User.stub(:find) { mock_user(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:user).should be(mock_user)
      end

      it "re-renders the 'edit' template" do
        pending
        User.stub(:find) { mock_user(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested user" do
      pending
      User.should_receive(:find).with("37") { mock_user }
      mock_user.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the users list" do
      pending
      User.stub(:find) { mock_user }
      delete :destroy, :id => "1"
      response.should redirect_to(users_url)
    end
  end

  describe "GET incompletes" do
    before :each do
      controller.stub(:current_user) {
        mock_user.stub(:incomplete_users) { ["1", "2", "3"] }
        mock_user
      }
    end

    it "renders the 'incompletes' template" do
      get :incompletes
      response.should render_template("incompletes")
    end

    it "send csv file when csv format" do
      User.should_receive(:incompletes_to_csv).with(no_args) { "test csv data" }
      get :incompletes, :format => "csv"
      response.header["Content-Disposition"].should include("評価未入力チェックシート")
      response.body.should == "test csv data"
    end
  end

  describe "GET result" do
    it "assigns an empty hash as @evaluation_item_map when no user's id passed" do
      get :result
      assigns(:evaluation_item_map).should be_empty
    end

    it "renders the 'result' template when no user's id passed" do
      get :result
      response.should render_template("result")
    end

    it "shows the evaluation result always when current_user is an administrator" do
      mock_roles = [mock_role]
      mock_roles.stub(:admin?) { true }
      controller.stub(:current_user) { mock_current_user(:roles => mock_roles) }
      User.stub(:find).with("1") { mock_user }
      User.stub(:make_users_scores!).with(mock_user) { [mock_user] }
      mock_user.should_receive(:evaluation_item_map) { mock_evaluation_item_map }
      get :result, :id => "1"
    end

    describe "when current_user is not an administrator" do
      before :each do
        mock_roles = [mock_role]
        mock_roles.stub(:admin?) { false }
        @controller.stub(:current_user) { mock_current_user(:roles => mock_roles) }

        mock_evaluation_trees = [ mock_evaluation_tree ]
        mock_evaluation_trees.stub(:topdown_only) { mock_evaluation_trees }
        mock_current_user.stub(:evaluation_trees) { mock_evaluation_trees }
      end

      describe "when System.evaluation_published_managers? returns true" do
        before :each do
          System.stub(:evaluation_published_managers?) { true }
          System.stub(:evaluation_published_employees?) { false }
        end

        it "should show the evaluation result of employee exists under the current_user's evaluation tree" do
          User.stub(:under_evaluation_tree).with(mock_evaluation_tree) { [mock_user] }
          User.stub(:find).with("1") { mock_user }
          User.stub(:make_users_scores!).with(mock_user) { [mock_user] }
          mock_user.should_receive(:evaluation_item_map) { mock_evaluation_item_map }
          get :result, :id => "1"
        end

        it "should not show the evaluation result of employee does not exist under the current_user's evaluation tree" do
          User.stub(:under_evaluation_tree).with(mock_evaluation_tree) { [] }
          User.stub(:find).with("1") { mock_user }
          User.stub(:make_users_scores!).with(mock_user) { [mock_user] }
          mock_user.should_not_receive(:evaluation_item_map)
          get :result, :id => "1"
        end

      end

      describe "when System.evaluation_published_employees? returns true" do
        before :each do
          System.stub(:evaluation_published_managers?) { false }
          System.stub(:evaluation_published_employees?) { true }
        end

        it "should show the evaluation result is current_user's" do
          User.stub(:find).with("1") { mock_current_user }
          User.stub(:make_users_scores!).with(mock_current_user) { [mock_current_user] }
          mock_current_user.should_receive(:evaluation_item_map) { mock_evaluation_item_map }
          get :result, :id => "1"
        end

        it "should not show the evaluation result is not current_user's" do
          User.stub(:find).with("1") { mock_user }
          User.stub(:make_users_scores!).with(mock_user) { [mock_user] }
          mock_user.should_not_receive(:evaluation_item_map)
          get :result, :id => "1"
        end
      end
    end

  end
end
