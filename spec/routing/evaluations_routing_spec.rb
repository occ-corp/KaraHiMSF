require "spec_helper"

describe EvaluationsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/evaluations" }.should route_to(:controller => "evaluations", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/evaluations/new" }.should route_to(:controller => "evaluations", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/evaluations/1" }.should route_to(:controller => "evaluations", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/evaluations/1/edit" }.should route_to(:controller => "evaluations", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/evaluations" }.should route_to(:controller => "evaluations", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/evaluations/1" }.should route_to(:controller => "evaluations", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/evaluations/1" }.should route_to(:controller => "evaluations", :action => "destroy", :id => "1")
    end

  end
end
