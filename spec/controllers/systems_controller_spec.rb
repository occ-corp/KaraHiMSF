require 'spec_helper'

describe SystemsController do

  def mock_system(stubs={})
    @mock_system ||= mock_model(System, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all systems as @systems" do
      System.stub(:all) { [mock_system] }
      get :index
      assigns(:systems).should eq([mock_system])
    end
  end

  describe "GET show" do
    it "assigns the requested system as @system" do
      System.stub(:find).with("37") { mock_system }
      get :show, :id => "37"
      assigns(:system).should be(mock_system)
    end
  end

  describe "GET new" do
    it "assigns a new system as @system" do
      System.stub(:new) { mock_system }
      get :new
      assigns(:system).should be(mock_system)
    end
  end

  describe "GET edit" do
    it "assigns the requested system as @system" do
      System.stub(:find).with("37") { mock_system }
      get :edit, :id => "37"
      assigns(:system).should be(mock_system)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created system as @system" do
        System.stub(:new).with({'these' => 'params'}) { mock_system(:save => true) }
        post :create, :system => {'these' => 'params'}
        assigns(:system).should be(mock_system)
      end

      it "redirects to the created system" do
        System.stub(:new) { mock_system(:save => true) }
        post :create, :system => {}
        response.should redirect_to(system_url(mock_system))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved system as @system" do
        System.stub(:new).with({'these' => 'params'}) { mock_system(:save => false) }
        post :create, :system => {'these' => 'params'}
        assigns(:system).should be(mock_system)
      end

      it "re-renders the 'new' template" do
        System.stub(:new) { mock_system(:save => false) }
        post :create, :system => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested system" do
        System.should_receive(:find).with("37") { mock_system }
        mock_system.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :system => {'these' => 'params'}
      end

      it "assigns the requested system as @system" do
        System.stub(:find) { mock_system(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:system).should be(mock_system)
      end

      it "redirects to the system" do
        System.stub(:find) { mock_system(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(system_url(mock_system))
      end
    end

    describe "with invalid params" do
      it "assigns the system as @system" do
        System.stub(:find) { mock_system(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:system).should be(mock_system)
      end

      it "re-renders the 'edit' template" do
        System.stub(:find) { mock_system(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested system" do
      System.should_receive(:find).with("37") { mock_system }
      mock_system.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the systems list" do
      System.stub(:find) { mock_system }
      delete :destroy, :id => "1"
      response.should redirect_to(systems_url)
    end
  end

end
