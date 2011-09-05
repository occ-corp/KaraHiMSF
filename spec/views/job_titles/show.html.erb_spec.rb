require 'spec_helper'

describe "job_titles/show.html.erb" do
  before(:each) do
    @job_title = assign(:job_title, stub_model(JobTitle))
  end

  it "renders attributes in <p>" do
    render
  end
end
