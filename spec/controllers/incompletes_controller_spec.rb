# -*- coding: utf-8 -*-
require 'spec_helper'
require 'spec_authentication_helper'

describe IncompletesController do
  include SpecAuthenticationHelper

  describe "GET 'index'" do
    before :each do
      controller.stub(:current_user) {
        mock_user.stub(:incomplete_users) { ["1", "2", "3"] }
        mock_user
      }
    end

    it "assigns users do not complete evaluation as @users when html format" do
      get :index
      assigns(:users).should == ["1", "2", "3"]
    end

    it "renders the 'index' template" do
      get :index
      response.should render_template("index")
    end

    it "send csv file when csv format" do
      User.stub(:incompletes_to_csv).with("1", "2", "3") { "test csv data" }
      get :index, :format => "csv"
      response.header["Content-Disposition"].should include("評価未入力チェックシート")
      response.body.should == "test csv data"
    end
  end

  describe "GET 'show'" do
    it "assigns incomplete evaluation items as @incompletes when params[:id] passed" do
      User.stub(:incompletes).with("37") { ["1", "2", "3"] }
      get :show, :id => "37"
      assigns(:incompletes).should == ["1", "2", "3"]
    end

    it "renders the 'show' template" do
      User.stub(:incompletes).with("37") { [] }
      get :show, :id => "37"
      response.should render_template("show")
    end
  end

end
