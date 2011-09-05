require "spec_helper"

describe SystemsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/systems" }.should route_to(:controller => "systems", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/systems/new" }.should route_to(:controller => "systems", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/systems/1" }.should route_to(:controller => "systems", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/systems/1/edit" }.should route_to(:controller => "systems", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/systems" }.should route_to(:controller => "systems", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/systems/1" }.should route_to(:controller => "systems", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/systems/1" }.should route_to(:controller => "systems", :action => "destroy", :id => "1")
    end

  end
end
