require "spec_helper"

describe ItemBelongsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/item_belongs" }.should route_to(:controller => "item_belongs", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/item_belongs/new" }.should route_to(:controller => "item_belongs", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/item_belongs/1" }.should route_to(:controller => "item_belongs", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/item_belongs/1/edit" }.should route_to(:controller => "item_belongs", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/item_belongs" }.should route_to(:controller => "item_belongs", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/item_belongs/1" }.should route_to(:controller => "item_belongs", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/item_belongs/1" }.should route_to(:controller => "item_belongs", :action => "destroy", :id => "1")
    end

  end
end
