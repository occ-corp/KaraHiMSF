require 'spec_helper'

describe "evaluation_orders/new.html.erb" do
  before(:each) do
    assign(:evaluation_order, stub_model(EvaluationOrder,
      :new_record? => true
    ))
  end

  it "renders new evaluation_order form" do
    render

    rendered.should have_selector("form", :action => evaluation_orders_path, :method => "post") do |form|
    end
  end
end
