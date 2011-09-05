require 'spec_helper'

describe EvaluationOrdersController do

  def mock_evaluation_order(stubs={})
    @mock_evaluation_order ||= mock_model(EvaluationOrder, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all evaluation_orders as @evaluation_orders" do
      EvaluationOrder.stub(:all) { [mock_evaluation_order] }
      get :index
      assigns(:evaluation_orders).should eq([mock_evaluation_order])
    end
  end

  describe "GET show" do
    it "assigns the requested evaluation_order as @evaluation_order" do
      EvaluationOrder.stub(:find).with("37") { mock_evaluation_order }
      get :show, :id => "37"
      assigns(:evaluation_order).should be(mock_evaluation_order)
    end
  end

  describe "GET new" do
    it "assigns a new evaluation_order as @evaluation_order" do
      EvaluationOrder.stub(:new) { mock_evaluation_order }
      get :new
      assigns(:evaluation_order).should be(mock_evaluation_order)
    end
  end

  describe "GET edit" do
    it "assigns the requested evaluation_order as @evaluation_order" do
      EvaluationOrder.stub(:find).with("37") { mock_evaluation_order }
      get :edit, :id => "37"
      assigns(:evaluation_order).should be(mock_evaluation_order)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created evaluation_order as @evaluation_order" do
        EvaluationOrder.stub(:new).with({'these' => 'params'}) { mock_evaluation_order(:save => true) }
        post :create, :evaluation_order => {'these' => 'params'}
        assigns(:evaluation_order).should be(mock_evaluation_order)
      end

      it "redirects to the created evaluation_order" do
        EvaluationOrder.stub(:new) { mock_evaluation_order(:save => true) }
        post :create, :evaluation_order => {}
        response.should redirect_to(evaluation_order_url(mock_evaluation_order))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved evaluation_order as @evaluation_order" do
        EvaluationOrder.stub(:new).with({'these' => 'params'}) { mock_evaluation_order(:save => false) }
        post :create, :evaluation_order => {'these' => 'params'}
        assigns(:evaluation_order).should be(mock_evaluation_order)
      end

      it "re-renders the 'new' template" do
        EvaluationOrder.stub(:new) { mock_evaluation_order(:save => false) }
        post :create, :evaluation_order => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested evaluation_order" do
        EvaluationOrder.should_receive(:find).with("37") { mock_evaluation_order }
        mock_evaluation_order.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :evaluation_order => {'these' => 'params'}
      end

      it "assigns the requested evaluation_order as @evaluation_order" do
        EvaluationOrder.stub(:find) { mock_evaluation_order(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:evaluation_order).should be(mock_evaluation_order)
      end

      it "redirects to the evaluation_order" do
        EvaluationOrder.stub(:find) { mock_evaluation_order(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(evaluation_order_url(mock_evaluation_order))
      end
    end

    describe "with invalid params" do
      it "assigns the evaluation_order as @evaluation_order" do
        EvaluationOrder.stub(:find) { mock_evaluation_order(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:evaluation_order).should be(mock_evaluation_order)
      end

      it "re-renders the 'edit' template" do
        EvaluationOrder.stub(:find) { mock_evaluation_order(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested evaluation_order" do
      EvaluationOrder.should_receive(:find).with("37") { mock_evaluation_order }
      mock_evaluation_order.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the evaluation_orders list" do
      EvaluationOrder.stub(:find) { mock_evaluation_order }
      delete :destroy, :id => "1"
      response.should redirect_to(evaluation_orders_url)
    end
  end

end
