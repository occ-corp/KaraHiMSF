require 'spec_helper'

describe "job_titles/index.html.erb" do
  before(:each) do
    assign(:job_titles, [
      stub_model(JobTitle),
      stub_model(JobTitle)
    ])
  end

  it "renders a list of job_titles" do
    render
  end
end
