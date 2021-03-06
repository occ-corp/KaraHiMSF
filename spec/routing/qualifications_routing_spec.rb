require "spec_helper"

describe QualificationsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/qualifications" }.should route_to(:controller => "qualifications", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/qualifications/new" }.should route_to(:controller => "qualifications", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/qualifications/1" }.should route_to(:controller => "qualifications", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/qualifications/1/edit" }.should route_to(:controller => "qualifications", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/qualifications" }.should route_to(:controller => "qualifications", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/qualifications/1" }.should route_to(:controller => "qualifications", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/qualifications/1" }.should route_to(:controller => "qualifications", :action => "destroy", :id => "1")
    end

  end
end
