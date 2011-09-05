require "spec_helper"

describe JobTitlesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/job_titles" }.should route_to(:controller => "job_titles", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/job_titles/new" }.should route_to(:controller => "job_titles", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/job_titles/1" }.should route_to(:controller => "job_titles", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/job_titles/1/edit" }.should route_to(:controller => "job_titles", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/job_titles" }.should route_to(:controller => "job_titles", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/job_titles/1" }.should route_to(:controller => "job_titles", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/job_titles/1" }.should route_to(:controller => "job_titles", :action => "destroy", :id => "1")
    end

  end
end
