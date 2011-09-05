require 'spec_helper'

describe "evaluation_orders/edit.html.erb" do
  before(:each) do
    @evaluation_order = assign(:evaluation_order, stub_model(EvaluationOrder,
      :new_record? => false
    ))
  end

  it "renders the edit evaluation_order form" do
    render

    rendered.should have_selector("form", :action => evaluation_order_path(@evaluation_order), :method => "post") do |form|
    end
  end
end
