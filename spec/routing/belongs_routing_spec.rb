require "spec_helper"

describe BelongsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/belongs" }.should route_to(:controller => "belongs", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/belongs/new" }.should route_to(:controller => "belongs", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/belongs/1" }.should route_to(:controller => "belongs", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/belongs/1/edit" }.should route_to(:controller => "belongs", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/belongs" }.should route_to(:controller => "belongs", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/belongs/1" }.should route_to(:controller => "belongs", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/belongs/1" }.should route_to(:controller => "belongs", :action => "destroy", :id => "1")
    end

  end
end
