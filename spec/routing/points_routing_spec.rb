require "spec_helper"

describe PointsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/points" }.should route_to(:controller => "points", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/points/new" }.should route_to(:controller => "points", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/points/1" }.should route_to(:controller => "points", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/points/1/edit" }.should route_to(:controller => "points", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/points" }.should route_to(:controller => "points", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/points/1" }.should route_to(:controller => "points", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/points/1" }.should route_to(:controller => "points", :action => "destroy", :id => "1")
    end

  end
end
