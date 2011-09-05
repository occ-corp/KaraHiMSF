require "spec_helper"

describe AdjustmentsController do
  describe "routing" do

    it "recognizes and generates #show" do
      { :get => "/adjustment" }.should route_to(:controller => "adjustments", :action => "show")
    end

    it "recognizes and generates #update" do
      { :put => "/adjustment" }.should route_to(:controller => "adjustments", :action => "update")
    end
  end
end
