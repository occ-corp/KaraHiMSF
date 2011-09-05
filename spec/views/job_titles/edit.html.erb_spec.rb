require 'spec_helper'

describe "job_titles/edit.html.erb" do
  before(:each) do
    @job_title = assign(:job_title, stub_model(JobTitle,
      :new_record? => false
    ))
  end

  it "renders the edit job_title form" do
    render

    rendered.should have_selector("form", :action => job_title_path(@job_title), :method => "post") do |form|
    end
  end
end
