require 'spec_helper'

describe EvaluationItemsController do

  def mock_evaluation_item(stubs={})
    @mock_evaluation_item ||= mock_model(EvaluationItem, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all evaluation_items as @evaluation_items" do
      EvaluationItem.stub(:all) { [mock_evaluation_item] }
      get :index
      assigns(:evaluation_items).should eq([mock_evaluation_item])
    end
  end

  describe "GET show" do
    it "assigns the requested evaluation_item as @evaluation_item" do
      EvaluationItem.stub(:find).with("37") { mock_evaluation_item }
      get :show, :id => "37"
      assigns(:evaluation_item).should be(mock_evaluation_item)
    end
  end

  describe "GET new" do
    it "assigns a new evaluation_item as @evaluation_item" do
      EvaluationItem.stub(:new) { mock_evaluation_item }
      get :new
      assigns(:evaluation_item).should be(mock_evaluation_item)
    end
  end

  describe "GET edit" do
    it "assigns the requested evaluation_item as @evaluation_item" do
      EvaluationItem.stub(:find).with("37") { mock_evaluation_item }
      get :edit, :id => "37"
      assigns(:evaluation_item).should be(mock_evaluation_item)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created evaluation_item as @evaluation_item" do
        EvaluationItem.stub(:new).with({'these' => 'params'}) { mock_evaluation_item(:save => true) }
        post :create, :evaluation_item => {'these' => 'params'}
        assigns(:evaluation_item).should be(mock_evaluation_item)
      end

      it "redirects to the created evaluation_item" do
        EvaluationItem.stub(:new) { mock_evaluation_item(:save => true) }
        post :create, :evaluation_item => {}
        response.should redirect_to(evaluation_item_url(mock_evaluation_item))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved evaluation_item as @evaluation_item" do
        EvaluationItem.stub(:new).with({'these' => 'params'}) { mock_evaluation_item(:save => false) }
        post :create, :evaluation_item => {'these' => 'params'}
        assigns(:evaluation_item).should be(mock_evaluation_item)
      end

      it "re-renders the 'new' template" do
        EvaluationItem.stub(:new) { mock_evaluation_item(:save => false) }
        post :create, :evaluation_item => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested evaluation_item" do
        EvaluationItem.should_receive(:find).with("37") { mock_evaluation_item }
        mock_evaluation_item.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :evaluation_item => {'these' => 'params'}
      end

      it "assigns the requested evaluation_item as @evaluation_item" do
        EvaluationItem.stub(:find) { mock_evaluation_item(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:evaluation_item).should be(mock_evaluation_item)
      end

      it "redirects to the evaluation_item" do
        EvaluationItem.stub(:find) { mock_evaluation_item(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(evaluation_item_url(mock_evaluation_item))
      end
    end

    describe "with invalid params" do
      it "assigns the evaluation_item as @evaluation_item" do
        EvaluationItem.stub(:find) { mock_evaluation_item(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:evaluation_item).should be(mock_evaluation_item)
      end

      it "re-renders the 'edit' template" do
        EvaluationItem.stub(:find) { mock_evaluation_item(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested evaluation_item" do
      EvaluationItem.should_receive(:find).with("37") { mock_evaluation_item }
      mock_evaluation_item.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the evaluation_items list" do
      EvaluationItem.stub(:find) { mock_evaluation_item }
      delete :destroy, :id => "1"
      response.should redirect_to(evaluation_items_url)
    end
  end

end
