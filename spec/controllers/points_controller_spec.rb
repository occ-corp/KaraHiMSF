require 'spec_helper'

describe PointsController do

  def mock_point(stubs={})
    @mock_point ||= mock_model(Point, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all points as @points" do
      Point.stub(:all) { [mock_point] }
      get :index
      assigns(:points).should eq([mock_point])
    end
  end

  describe "GET show" do
    it "assigns the requested point as @point" do
      Point.stub(:find).with("37") { mock_point }
      get :show, :id => "37"
      assigns(:point).should be(mock_point)
    end
  end

  describe "GET new" do
    it "assigns a new point as @point" do
      Point.stub(:new) { mock_point }
      get :new
      assigns(:point).should be(mock_point)
    end
  end

  describe "GET edit" do
    it "assigns the requested point as @point" do
      Point.stub(:find).with("37") { mock_point }
      get :edit, :id => "37"
      assigns(:point).should be(mock_point)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created point as @point" do
        Point.stub(:new).with({'these' => 'params'}) { mock_point(:save => true) }
        post :create, :point => {'these' => 'params'}
        assigns(:point).should be(mock_point)
      end

      it "redirects to the created point" do
        Point.stub(:new) { mock_point(:save => true) }
        post :create, :point => {}
        response.should redirect_to(point_url(mock_point))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved point as @point" do
        Point.stub(:new).with({'these' => 'params'}) { mock_point(:save => false) }
        post :create, :point => {'these' => 'params'}
        assigns(:point).should be(mock_point)
      end

      it "re-renders the 'new' template" do
        Point.stub(:new) { mock_point(:save => false) }
        post :create, :point => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested point" do
        Point.should_receive(:find).with("37") { mock_point }
        mock_point.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :point => {'these' => 'params'}
      end

      it "assigns the requested point as @point" do
        Point.stub(:find) { mock_point(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:point).should be(mock_point)
      end

      it "redirects to the point" do
        Point.stub(:find) { mock_point(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(point_url(mock_point))
      end
    end

    describe "with invalid params" do
      it "assigns the point as @point" do
        Point.stub(:find) { mock_point(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:point).should be(mock_point)
      end

      it "re-renders the 'edit' template" do
        Point.stub(:find) { mock_point(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested point" do
      Point.should_receive(:find).with("37") { mock_point }
      mock_point.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the points list" do
      Point.stub(:find) { mock_point }
      delete :destroy, :id => "1"
      response.should redirect_to(points_url)
    end
  end

end
