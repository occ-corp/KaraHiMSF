require 'spec_helper'

describe "evaluation_items/edit.html.erb" do
  before(:each) do
    @evaluation_item = assign(:evaluation_item, stub_model(EvaluationItem,
      :new_record? => false
    ))
  end

  it "renders the edit evaluation_item form" do
    render

    rendered.should have_selector("form", :action => evaluation_item_path(@evaluation_item), :method => "post") do |form|
    end
  end
end
