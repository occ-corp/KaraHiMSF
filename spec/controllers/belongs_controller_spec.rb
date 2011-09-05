require 'spec_helper'

describe BelongsController do

  def mock_belong(stubs={})
    @mock_belong ||= mock_model(Belong, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all belongs as @belongs" do
      Belong.stub(:all) { [mock_belong] }
      get :index
      assigns(:belongs).should eq([mock_belong])
    end
  end

  describe "GET show" do
    it "assigns the requested belong as @belong" do
      Belong.stub(:find).with("37") { mock_belong }
      get :show, :id => "37"
      assigns(:belong).should be(mock_belong)
    end
  end

  describe "GET new" do
    it "assigns a new belong as @belong" do
      Belong.stub(:new) { mock_belong }
      get :new
      assigns(:belong).should be(mock_belong)
    end
  end

  describe "GET edit" do
    it "assigns the requested belong as @belong" do
      Belong.stub(:find).with("37") { mock_belong }
      get :edit, :id => "37"
      assigns(:belong).should be(mock_belong)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created belong as @belong" do
        Belong.stub(:new).with({'these' => 'params'}) { mock_belong(:save => true) }
        post :create, :belong => {'these' => 'params'}
        assigns(:belong).should be(mock_belong)
      end

      it "redirects to the created belong" do
        Belong.stub(:new) { mock_belong(:save => true) }
        post :create, :belong => {}
        response.should redirect_to(belong_url(mock_belong))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved belong as @belong" do
        Belong.stub(:new).with({'these' => 'params'}) { mock_belong(:save => false) }
        post :create, :belong => {'these' => 'params'}
        assigns(:belong).should be(mock_belong)
      end

      it "re-renders the 'new' template" do
        Belong.stub(:new) { mock_belong(:save => false) }
        post :create, :belong => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested belong" do
        Belong.should_receive(:find).with("37") { mock_belong }
        mock_belong.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :belong => {'these' => 'params'}
      end

      it "assigns the requested belong as @belong" do
        Belong.stub(:find) { mock_belong(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:belong).should be(mock_belong)
      end

      it "redirects to the belong" do
        Belong.stub(:find) { mock_belong(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(belong_url(mock_belong))
      end
    end

    describe "with invalid params" do
      it "assigns the belong as @belong" do
        Belong.stub(:find) { mock_belong(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:belong).should be(mock_belong)
      end

      it "re-renders the 'edit' template" do
        Belong.stub(:find) { mock_belong(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested belong" do
      Belong.should_receive(:find).with("37") { mock_belong }
      mock_belong.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the belongs list" do
      Belong.stub(:find) { mock_belong }
      delete :destroy, :id => "1"
      response.should redirect_to(belongs_url)
    end
  end

end
