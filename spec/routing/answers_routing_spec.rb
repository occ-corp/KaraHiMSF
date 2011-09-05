require "spec_helper"

describe AnswersController do
  describe "routing" do

    it "recognizes and generates #create" do
      { :post => "/answers" }.should route_to(:controller => "answers", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/answers/1" }.should route_to(:controller => "answers", :action => "update", :id => "1")
    end

  end
end
