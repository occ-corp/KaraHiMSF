require "spec_helper"

describe EvaluationCategoriesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/evaluation_categories" }.should route_to(:controller => "evaluation_categories", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/evaluation_categories/new" }.should route_to(:controller => "evaluation_categories", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/evaluation_categories/1" }.should route_to(:controller => "evaluation_categories", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/evaluation_categories/1/edit" }.should route_to(:controller => "evaluation_categories", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/evaluation_categories" }.should route_to(:controller => "evaluation_categories", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/evaluation_categories/1" }.should route_to(:controller => "evaluation_categories", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/evaluation_categories/1" }.should route_to(:controller => "evaluation_categories", :action => "destroy", :id => "1")
    end

  end
end
