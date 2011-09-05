# -*- coding: utf-8 -*-

require 'spec_helper'

describe Division do
  # pending "add some examples to (or delete) #{__FILE__}"

  describe "about better nested set" do
    before :each do
      @division = Division.create :name => 'parent division'
      Division.create(:name => 'child division 1').move_to_child_of @division
      Division.create(:name => 'child division 2').move_to_child_of @division
    end

    it "should be able to have some children" do
      @division.children.count.should == 2
    end

    it "should have #level which returns a nest level" do
      @division.respond_to?(:level).should be_true
      @division.level.should be_zero
      @division.children.first.respond_to?(:level).should be_true
      @division.children.first.level.should == 1
    end

    it "should be able to return its nested name" do
      @division.children.first.nested_name.should == ('　' * @division.children.first.level) + @division.children.first.name
    end
  end
end
