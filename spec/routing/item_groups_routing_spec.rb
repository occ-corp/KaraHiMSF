require "spec_helper"

describe ItemGroupsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/item_groups" }.should route_to(:controller => "item_groups", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/item_groups/new/1" }.should route_to(:controller => "item_groups", :action => "new", :id => "1")
      { :get => "/item_groups/new" }.should route_to(:controller => "item_groups", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/item_groups/1" }.should route_to(:controller => "item_groups", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/item_groups/1/edit" }.should route_to(:controller => "item_groups", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/item_groups" }.should route_to(:controller => "item_groups", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/item_groups/1" }.should route_to(:controller => "item_groups", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/item_groups/1" }.should route_to(:controller => "item_groups", :action => "destroy", :id => "1")
    end

  end
end
