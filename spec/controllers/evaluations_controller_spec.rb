require 'spec_helper'

describe EvaluationsController do

  def mock_evaluation(stubs={})
    @mock_evaluation ||= mock_model(Evaluation, stubs).as_null_object
  end

  def mock_current_user(stubs={})
    @mock_current_user ||= mock_model(User, stubs).as_null_object
  end

  before :each do
    controller.stub(:current_user) { mock_current_user }
  end

  describe "GET index" do
    it "assigns the users as @users" do
      users = User.all
      users.stub(:scoped_by_phrase) { users }
      users.stub(:paginate) { users }
      User.stub(:scoped_by_division_full_set).with("1") { users }
      get :index, :division_id => "1"
      assigns(:users).should == users
    end
  end
end
