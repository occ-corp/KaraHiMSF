require 'spec_helper'

describe AnswersController do

  def mock_current_user(stubs={ })
    (@current_user ||= mock_model(User).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  def mock_answer(stubs={})
    (@mock_answer ||= mock_model(Answer).as_null_object).tap do |answer|
      answer.stub(stubs) unless stubs.empty?
    end
  end

  before :each do
    request.env["HTTP_REFERER"] = "/"
    @controller.stub(:current_user) { mock_current_user }
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created answer as @answer" do
        Answer.stub(:new).with({'these' => 'params'}) { mock_answer(:save => true) }
        post :create, :answer => {'these' => 'params'}
        assigns(:answer).should be(mock_answer)
      end

      it "responses success" do
        Answer.stub(:new) { mock_answer(:save => true) }
        post :create, :answer => {}
        response.should redirect_to("/")
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved answer as @answer" do
        Answer.stub(:new).with({'these' => 'params'}) { mock_answer(:save => false) }
        post :create, :answer => {'these' => 'params'}
        assigns(:answer).should be(mock_answer)
      end

      it "re-renders the 'new' template" do
        Answer.stub(:new) { mock_answer(:save => false) }
        post :create, :answer => {}
        response.should redirect_to("/")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested answer" do
        Answer.should_receive(:find).with("37") { mock_answer }
        mock_answer.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :answer => {'these' => 'params'}
      end

      it "assigns the requested answer as @answer" do
        Answer.stub(:find) { mock_answer(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:answer).should be(mock_answer)
      end

      it "redirects to the answer" do
        Answer.stub(:find) { mock_answer(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to("/")
      end
    end

    describe "with invalid params" do
      it "assigns the answer as @answer" do
        Answer.stub(:find) { mock_answer(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:answer).should be(mock_answer)
      end

      it "re-renders the 'edit' template" do
        Answer.stub(:find) { mock_answer(:update_attributes => false) }
        put :update, :id => "1"
        response.should redirect_to("/")
      end
    end

  end

end
