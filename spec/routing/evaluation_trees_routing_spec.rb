require "spec_helper"

describe EvaluationTreesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/evaluation_trees" }.should route_to(:controller => "evaluation_trees", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/evaluation_trees/new" }.should route_to(:controller => "evaluation_trees", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/evaluation_trees/1" }.should route_to(:controller => "evaluation_trees", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/evaluation_trees/1/edit" }.should route_to(:controller => "evaluation_trees", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/evaluation_trees" }.should route_to(:controller => "evaluation_trees", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/evaluation_trees/1" }.should route_to(:controller => "evaluation_trees", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/evaluation_trees/1" }.should route_to(:controller => "evaluation_trees", :action => "destroy", :id => "1")
    end

  end
end
