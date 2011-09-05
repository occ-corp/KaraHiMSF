require "spec_helper"

describe ScoresController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/scores" }.should route_to(:controller => "scores", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/scores/new" }.should route_to(:controller => "scores", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/scores/1" }.should route_to(:controller => "scores", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/scores/1/edit" }.should route_to(:controller => "scores", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/scores" }.should route_to(:controller => "scores", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/scores/1" }.should route_to(:controller => "scores", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/scores/1" }.should route_to(:controller => "scores", :action => "destroy", :id => "1")
    end

  end
end
