require 'spec_helper'

describe "job_titles/new.html.erb" do
  before(:each) do
    assign(:job_title, stub_model(JobTitle,
      :new_record? => true
    ))
  end

  it "renders new job_title form" do
    render

    rendered.should have_selector("form", :action => job_titles_path, :method => "post") do |form|
    end
  end
end
