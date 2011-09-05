require 'spec_helper'

describe ItemGroupsController do

  def mock_item_group(stubs={})
    @mock_item_group ||= mock_model(ItemGroup, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all item_groups as @item_groups" do
      ItemGroup.stub(:all) { [mock_item_group] }
      get :index
      assigns(:item_groups).should eq([mock_item_group])
    end
  end

  describe "GET show" do
    it "assigns the requested item_group as @item_group" do
      mock_item_groups = []
      mock_item_groups.stub(:find).with("37") { mock_item_group }
      ItemGroup.stub(:order_by_evaluation_category_id) { mock_item_groups }
      get :show, :id => "37"
      assigns(:item_group).should be(mock_item_group)
    end
  end

  describe "GET new" do
    it "assigns a new item_group as @item_group" do
      ItemGroup.stub(:new) { mock_item_group }
      get :new
      assigns(:item_group).should be(mock_item_group)
    end

    it "assigns a duplicated item_group as @item_group" do
      new_item_grop = ItemGroup.new
      mock_item_group.stub(:duplicate) { new_item_grop }
      mock_item_groups = []
      mock_item_groups.stub(:find).with("27") { mock_item_group }
      ItemGroup.stub(:order_by_evaluation_category_id) { mock_item_groups }
      get :new, :id => "27"
      assigns(:item_group).should be(new_item_grop)
    end
  end

  describe "GET edit" do
    it "assigns the requested item_group as @item_group" do
      ItemGroup.stub(:find).with("37") { mock_item_group }
      get :edit, :id => "37"
      assigns(:item_group).should be(mock_item_group)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created item_group as @item_group" do
        ItemGroup.stub(:new).with({'these' => 'params'}) { mock_item_group(:save => true) }
        post :create, :item_group => {'these' => 'params'}
        assigns(:item_group).should be(mock_item_group)
      end

      it "redirects to the created item_group" do
        ItemGroup.stub(:new) { mock_item_group(:save => true) }
        post :create, :item_group => {}
        response.should redirect_to(item_groups_url)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved item_group as @item_group" do
        ItemGroup.stub(:new).with({'these' => 'params'}) { mock_item_group(:save => false) }
        post :create, :item_group => {'these' => 'params'}
        assigns(:item_group).should be(mock_item_group)
      end

      it "re-renders the 'new' template" do
        ItemGroup.stub(:new) { mock_item_group(:save => false) }
        post :create, :item_group => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested item_group" do
        ItemGroup.should_receive(:find).with("37") { mock_item_group }
        mock_item_group.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :item_group => {'these' => 'params'}
      end

      it "assigns the requested item_group as @item_group" do
        ItemGroup.stub(:find) { mock_item_group(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:item_group).should be(mock_item_group)
      end

      it "redirects to the item_group" do
        ItemGroup.stub(:find) { mock_item_group(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(item_groups_url)
      end
    end

    describe "with invalid params" do
      it "assigns the item_group as @item_group" do
        ItemGroup.stub(:find) { mock_item_group(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:item_group).should be(mock_item_group)
      end

      it "re-renders the 'edit' template" do
        ItemGroup.stub(:find) { mock_item_group(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested item_group" do
      ItemGroup.should_receive(:find).with("37") { mock_item_group }
      mock_item_group.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the item_groups list" do
      ItemGroup.stub(:find) { mock_item_group }
      delete :destroy, :id => "1"
      response.should redirect_to(item_groups_url)
    end
  end

end
