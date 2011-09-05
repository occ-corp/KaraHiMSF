require 'spec_helper'

describe ItemBelongsController do

  def mock_item_belong(stubs={})
    @mock_item_belong ||= mock_model(ItemBelong, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all item_belongs as @item_belongs" do
      ItemBelong.stub(:all) { [mock_item_belong] }
      get :index
      assigns(:item_belongs).should eq([mock_item_belong])
    end
  end

  describe "GET show" do
    it "assigns the requested item_belong as @item_belong" do
      ItemBelong.stub(:find).with("37") { mock_item_belong }
      get :show, :id => "37"
      assigns(:item_belong).should be(mock_item_belong)
    end
  end

  describe "GET new" do
    it "assigns a new item_belong as @item_belong" do
      ItemBelong.stub(:new) { mock_item_belong }
      get :new
      assigns(:item_belong).should be(mock_item_belong)
    end
  end

  describe "GET edit" do
    it "assigns the requested item_belong as @item_belong" do
      ItemBelong.stub(:find).with("37") { mock_item_belong }
      get :edit, :id => "37"
      assigns(:item_belong).should be(mock_item_belong)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created item_belong as @item_belong" do
        ItemBelong.stub(:new).with({'these' => 'params'}) { mock_item_belong(:save => true) }
        post :create, :item_belong => {'these' => 'params'}
        assigns(:item_belong).should be(mock_item_belong)
      end

      it "redirects to the created item_belong" do
        ItemBelong.stub(:new) { mock_item_belong(:save => true) }
        post :create, :item_belong => {}
        response.should redirect_to(item_belong_url(mock_item_belong))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved item_belong as @item_belong" do
        ItemBelong.stub(:new).with({'these' => 'params'}) { mock_item_belong(:save => false) }
        post :create, :item_belong => {'these' => 'params'}
        assigns(:item_belong).should be(mock_item_belong)
      end

      it "re-renders the 'new' template" do
        ItemBelong.stub(:new) { mock_item_belong(:save => false) }
        post :create, :item_belong => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested item_belong" do
        ItemBelong.should_receive(:find).with("37") { mock_item_belong }
        mock_item_belong.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :item_belong => {'these' => 'params'}
      end

      it "assigns the requested item_belong as @item_belong" do
        ItemBelong.stub(:find) { mock_item_belong(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:item_belong).should be(mock_item_belong)
      end

      it "redirects to the item_belong" do
        ItemBelong.stub(:find) { mock_item_belong(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(item_belong_url(mock_item_belong))
      end
    end

    describe "with invalid params" do
      it "assigns the item_belong as @item_belong" do
        ItemBelong.stub(:find) { mock_item_belong(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:item_belong).should be(mock_item_belong)
      end

      it "re-renders the 'edit' template" do
        ItemBelong.stub(:find) { mock_item_belong(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested item_belong" do
      ItemBelong.should_receive(:find).with("37") { mock_item_belong }
      mock_item_belong.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the item_belongs list" do
      ItemBelong.stub(:find) { mock_item_belong }
      delete :destroy, :id => "1"
      response.should redirect_to(item_belongs_url)
    end
  end

end
