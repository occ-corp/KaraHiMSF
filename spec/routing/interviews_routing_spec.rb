require "spec_helper"

describe InterviewsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/interviews" }.should route_to(:controller => "interviews", :action => "index")
    end

    it "recognizes and generates #create" do
      { :post => "/interviews" }.should route_to(:controller => "interviews", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/interviews/1" }.should route_to(:controller => "interviews", :action => "update", :id => "1")
    end
  end
end
