require 'spec_helper'

describe EvaluationCategoriesController do

  def mock_evaluation_category(stubs={})
    @mock_evaluation_category ||= mock_model(EvaluationCategory, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all evaluation_categories as @evaluation_categories" do
      EvaluationCategory.stub(:all) { [mock_evaluation_category] }
      get :index
      assigns(:evaluation_categories).should eq([mock_evaluation_category])
    end
  end

  describe "GET show" do
    it "assigns the requested evaluation_category as @evaluation_category" do
      EvaluationCategory.stub(:find).with("37") { mock_evaluation_category }
      get :show, :id => "37"
      assigns(:evaluation_category).should be(mock_evaluation_category)
    end
  end

  describe "GET new" do
    it "assigns a new evaluation_category as @evaluation_category" do
      EvaluationCategory.stub(:new) { mock_evaluation_category }
      get :new
      assigns(:evaluation_category).should be(mock_evaluation_category)
    end
  end

  describe "GET edit" do
    it "assigns the requested evaluation_category as @evaluation_category" do
      EvaluationCategory.stub(:find).with("37") { mock_evaluation_category }
      get :edit, :id => "37"
      assigns(:evaluation_category).should be(mock_evaluation_category)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created evaluation_category as @evaluation_category" do
        EvaluationCategory.stub(:new).with({'these' => 'params'}) { mock_evaluation_category(:save => true) }
        post :create, :evaluation_category => {'these' => 'params'}
        assigns(:evaluation_category).should be(mock_evaluation_category)
      end

      it "redirects to the created evaluation_category" do
        EvaluationCategory.stub(:new) { mock_evaluation_category(:save => true) }
        post :create, :evaluation_category => {}
        response.should redirect_to(evaluation_category_url(mock_evaluation_category))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved evaluation_category as @evaluation_category" do
        EvaluationCategory.stub(:new).with({'these' => 'params'}) { mock_evaluation_category(:save => false) }
        post :create, :evaluation_category => {'these' => 'params'}
        assigns(:evaluation_category).should be(mock_evaluation_category)
      end

      it "re-renders the 'new' template" do
        EvaluationCategory.stub(:new) { mock_evaluation_category(:save => false) }
        post :create, :evaluation_category => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested evaluation_category" do
        EvaluationCategory.should_receive(:find).with("37") { mock_evaluation_category }
        mock_evaluation_category.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :evaluation_category => {'these' => 'params'}
      end

      it "assigns the requested evaluation_category as @evaluation_category" do
        EvaluationCategory.stub(:find) { mock_evaluation_category(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:evaluation_category).should be(mock_evaluation_category)
      end

      it "redirects to the evaluation_category" do
        EvaluationCategory.stub(:find) { mock_evaluation_category(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(evaluation_category_url(mock_evaluation_category))
      end
    end

    describe "with invalid params" do
      it "assigns the evaluation_category as @evaluation_category" do
        EvaluationCategory.stub(:find) { mock_evaluation_category(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:evaluation_category).should be(mock_evaluation_category)
      end

      it "re-renders the 'edit' template" do
        EvaluationCategory.stub(:find) { mock_evaluation_category(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested evaluation_category" do
      EvaluationCategory.should_receive(:find).with("37") { mock_evaluation_category }
      mock_evaluation_category.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the evaluation_categories list" do
      EvaluationCategory.stub(:find) { mock_evaluation_category }
      delete :destroy, :id => "1"
      response.should redirect_to(evaluation_categories_url)
    end
  end

end
