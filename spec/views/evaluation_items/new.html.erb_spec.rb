require 'spec_helper'

describe "evaluation_items/new.html.erb" do
  before(:each) do
    assign(:evaluation_item, stub_model(EvaluationItem,
      :new_record? => true
    ))
  end

  it "renders new evaluation_item form" do
    render

    rendered.should have_selector("form", :action => evaluation_items_path, :method => "post") do |form|
    end
  end
end
