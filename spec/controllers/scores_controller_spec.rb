require 'spec_helper'
require 'spec_authentication_helper'

describe ScoresController do
  include SpecAuthenticationHelper

  def mock_score(stubs={})
    @mock_score ||= mock_model(Score, stubs).as_null_object
  end

  def mock_evaluation_category(stubs={})
    @mock_evaluation_category ||= mock_model(EvaluationCategory, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns a user as @user" do
      get :index, :user_id => mock_user.id
      assigns(:user).should equal(mock_user)
    end

    it "renders the 'index' template" do
      get :index, :user_id => mock_user.id
      response.should render_template("index")
    end

    describe "with Ajax request" do
      before :each do
        mock_user.stub(:build_evaluation_score_sheet) { '' }
      end

      it "should response JSON" do
        @controller.should_receive(:render).with(no_args)
        @controller.should_receive(:render).with({:json => ''})
        xhr :get, :index, :user_id => mock_user.id, :format => "json"
      end

      describe "when a evaluaton_category which is not a kind of EvaluationCategory::Multifaceted passed" do
        it "should set with_others_evaluations=true to User#build_evaluation_score_sheet" do
          mock_evaluation_category = mock_model(EvaluationCategory::TopDown)
          EvaluationCategory.should_receive(:find).with(mock_evaluation_category) { mock_evaluation_category }
          mock_user.should_receive(:build_evaluation_score_sheet).with(nil, mock_evaluation_category, true)
          xhr :get, :index, :user_id => mock_user.id, :format => "json", :evaluation_category_id => mock_evaluation_category
        end
      end

      describe "when a evaluaton_category which is a kind of EvaluationCategory::Multifaceted passed" do
        it "should set with_others_evaluations=false to User#build_evaluation_score_sheet" do
          mock_evaluation_category = mock_model(EvaluationCategory::Multifaceted)
          EvaluationCategory.should_receive(:find).with(mock_evaluation_category) { mock_evaluation_category }
          mock_user.should_receive(:build_evaluation_score_sheet).with(nil, mock_evaluation_category, false)
          xhr :get, :index, :user_id => mock_user.id, :format => "json", :evaluation_category_id => mock_evaluation_category
        end
      end
    end

    describe "without Ajax request" do
      before :each do
        EvaluationCategory.stub(:find).with("27") { mock_evaluation_category }
        @evaluation_type = mock_evaluation_category.class.evaluation_type
        @mock_users = [mock_model(User)]
        @mock_users.stub(:scope_by_evaluation_order_type).with(@evaluation_type) { @mock_users }
        @mock_users.stub(:scoped_by_phrase) { @mock_users }
        @mock_users.stub(:only_unevaluated) { @mock_users }
        @mock_users.stub(:order_by_user_kana) { @mock_users }
        @mock_users.stub(:paginate) { @mock_users }
        mock_user.stub(:object_users) { @mock_users }
        controller.session.delete :scores
      end

      it "assigns an evaluation_category as @evaluation_category" do
        get :index, :evaluation_category_id => "27"
        assigns(:evaluation_category).should be(mock_evaluation_category)
      end

      it "assigns an evaluation_order_type as @evaluation_type" do
        get :index, :evaluation_category_id => "27"
        assigns(:evaluation_type).should be(@evaluation_type)
      end

      it "assigns object users as @object_users" do
        get :index, :evaluation_category_id => "27"
        assigns(:object_users).should == @mock_users
      end

      it "should call User#only_unevaluated when params[:only_unevaluated] is equal \"true\"" do
        @mock_users.should_receive(:only_unevaluated).with(current_user, mock_evaluation_category) {  @mock_users }
        get :index, :evaluation_category_id => "27", :only_unevaluated => "true"
      end

      it "should not call User#only_unevaluated when params[:only_unevaluated] is not equal \"true\"" do
        @mock_users.should_not_receive(:only_unevaluated)
        get :index, :evaluation_category_id => "27", :only_unevaluated => ""
      end

      it "assigns object users sorted by users.kana when params[:only_unevaluated] is equal \"true\"" do
        @mock_users.should_receive(:order_by_user_kana) { @mock_users }
        get :index, :evaluation_category_id => "27"
      end

      it "assigns object users sorted by users.kana when params[:only_unevaluated] is equal \"true\"" do
        @mock_users.should_receive(:order_by_user_kana) { @mock_users }
        get :index, :evaluation_category_id => "27"
      end
    end
  end

  describe "GET show" do
    it "assigns the requested score as @score" do
      Score.stub(:find).with("37") { mock_score }
      get :show, :id => "37", :user_id => "1"
      assigns(:score).should be(mock_score)
    end
  end

  describe "GET new" do
    it "assigns a new score as @score" do
      Score.stub(:new) { mock_score }
      get :new, :user_id => "1"
      assigns(:score).should be(mock_score)
    end
  end

  describe "GET edit" do
    it "assigns the requested score as @score" do
      Score.stub(:find).with("37") { mock_score }
      get :edit, :id => "37", :user_id => "1"
      assigns(:score).should be(mock_score)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created score as @score" do
        Score.stub(:new).with({'these' => 'params'}) { mock_score(:save => true) }
        post :create, :user_id => "1", :score => {'these' => 'params'}
        assigns(:score).should be(mock_score)
      end

      it "redirects to the created score" do
        Score.stub(:new) { mock_score(:save => true) }
        post :create, :user_id => "1", :score => {}
        response.should redirect_to(user_score_url(:id => mock_score, :user_id => "1"))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved score as @score" do
        Score.stub(:new).with({'these' => 'params'}) { mock_score(:save => false) }
        post :create, :user_id => "1", :score => {'these' => 'params'}
        assigns(:score).should be(mock_score)
      end

      it "re-renders the 'new' template" do
        Score.stub(:new) { mock_score(:save => false) }
        post :create, :user_id => "1", :score => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested score" do
        Score.should_receive(:find).with("37") { mock_score }
        mock_score.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :user_id => "1", :score => {'these' => 'params'}
      end

      it "assigns the requested score as @score" do
        Score.stub(:find) { mock_score(:update_attributes => true) }
        put :update, :id => "1", :user_id => "1"
        assigns(:score).should be(mock_score)
      end

      it "redirects to the score" do
        Score.stub(:find) { mock_score(:update_attributes => true) }
        put :update, :id => "1", :user_id => "1"
        response.should redirect_to(user_score_url(:id => mock_score, :user_id => "1"))
      end
    end

    describe "with invalid params" do
      it "assigns the score as @score" do
        Score.stub(:find) { mock_score(:update_attributes => false) }
        put :update, :id => "1", :user_id => "1"
        assigns(:score).should be(mock_score)
      end

      it "re-renders the 'edit' template" do
        Score.stub(:find) { mock_score(:update_attributes => false) }
        put :update, :id => "1", :user_id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested score" do
      Score.should_receive(:find).with("37") { mock_score }
      mock_score.should_receive(:destroy)
      delete :destroy, :id => "37", :user_id => "1"
    end

    it "redirects to the scores list" do
      Score.stub(:find) { mock_score }
      delete :destroy, :id => "1", :user_id => "1"
      response.should redirect_to(user_scores_url(:user_id => "1"))
    end
  end

end
