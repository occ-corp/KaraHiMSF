require 'spec_helper'

describe JobTitlesController do

  def mock_job_title(stubs={})
    @mock_job_title ||= mock_model(JobTitle, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all job_titles as @job_titles" do
      JobTitle.stub(:all) { [mock_job_title] }
      get :index
      assigns(:job_titles).should eq([mock_job_title])
    end
  end

  describe "GET show" do
    it "assigns the requested job_title as @job_title" do
      JobTitle.stub(:find).with("37") { mock_job_title }
      get :show, :id => "37"
      assigns(:job_title).should be(mock_job_title)
    end
  end

  describe "GET new" do
    it "assigns a new job_title as @job_title" do
      JobTitle.stub(:new) { mock_job_title }
      get :new
      assigns(:job_title).should be(mock_job_title)
    end
  end

  describe "GET edit" do
    it "assigns the requested job_title as @job_title" do
      JobTitle.stub(:find).with("37") { mock_job_title }
      get :edit, :id => "37"
      assigns(:job_title).should be(mock_job_title)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created job_title as @job_title" do
        JobTitle.stub(:new).with({'these' => 'params'}) { mock_job_title(:save => true) }
        post :create, :job_title => {'these' => 'params'}
        assigns(:job_title).should be(mock_job_title)
      end

      it "redirects to the created job_title" do
        JobTitle.stub(:new) { mock_job_title(:save => true) }
        post :create, :job_title => {}
        response.should redirect_to(job_title_url(mock_job_title))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved job_title as @job_title" do
        JobTitle.stub(:new).with({'these' => 'params'}) { mock_job_title(:save => false) }
        post :create, :job_title => {'these' => 'params'}
        assigns(:job_title).should be(mock_job_title)
      end

      it "re-renders the 'new' template" do
        JobTitle.stub(:new) { mock_job_title(:save => false) }
        post :create, :job_title => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested job_title" do
        JobTitle.should_receive(:find).with("37") { mock_job_title }
        mock_job_title.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :job_title => {'these' => 'params'}
      end

      it "assigns the requested job_title as @job_title" do
        JobTitle.stub(:find) { mock_job_title(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:job_title).should be(mock_job_title)
      end

      it "redirects to the job_title" do
        JobTitle.stub(:find) { mock_job_title(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(job_title_url(mock_job_title))
      end
    end

    describe "with invalid params" do
      it "assigns the job_title as @job_title" do
        JobTitle.stub(:find) { mock_job_title(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:job_title).should be(mock_job_title)
      end

      it "re-renders the 'edit' template" do
        JobTitle.stub(:find) { mock_job_title(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested job_title" do
      JobTitle.should_receive(:find).with("37") { mock_job_title }
      mock_job_title.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the job_titles list" do
      JobTitle.stub(:find) { mock_job_title }
      delete :destroy, :id => "1"
      response.should redirect_to(job_titles_url)
    end
  end

end
