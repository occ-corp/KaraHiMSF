require "spec_helper"

describe EvaluationOrdersController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/evaluation_orders" }.should route_to(:controller => "evaluation_orders", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/evaluation_orders/new" }.should route_to(:controller => "evaluation_orders", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/evaluation_orders/1" }.should route_to(:controller => "evaluation_orders", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/evaluation_orders/1/edit" }.should route_to(:controller => "evaluation_orders", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/evaluation_orders" }.should route_to(:controller => "evaluation_orders", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/evaluation_orders/1" }.should route_to(:controller => "evaluation_orders", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/evaluation_orders/1" }.should route_to(:controller => "evaluation_orders", :action => "destroy", :id => "1")
    end

  end
end
