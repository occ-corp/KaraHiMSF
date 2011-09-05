require "spec_helper"

describe EvaluationItemsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/evaluation_items" }.should route_to(:controller => "evaluation_items", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/evaluation_items/new" }.should route_to(:controller => "evaluation_items", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/evaluation_items/1" }.should route_to(:controller => "evaluation_items", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/evaluation_items/1/edit" }.should route_to(:controller => "evaluation_items", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/evaluation_items" }.should route_to(:controller => "evaluation_items", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/evaluation_items/1" }.should route_to(:controller => "evaluation_items", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/evaluation_items/1" }.should route_to(:controller => "evaluation_items", :action => "destroy", :id => "1")
    end

  end
end
