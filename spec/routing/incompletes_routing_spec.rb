require "spec_helper"

describe IncompletesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/incompletes" }.should route_to(:controller => "incompletes", :action => "index")
    end

    it "recognizes and generates #show" do
      { :get => "/incompletes/1" }.should route_to(:controller => "incompletes", :action => "show", :id => "1")
    end

  end
end
