# -*- coding: utf-8 -*-

class ItemGroup < ActiveRecord::Base
  has_many :users
  has_many :item_belongs, :dependent => :destroy
  has_many :items, :through => :item_belongs

  accepts_nested_attributes_for :item_belongs, :allow_destroy => true
  attr_accessible :item_belongs_attributes, :name

  validates_uniqueness_of :name, :on => :create

  scope :order_by_evaluation_category_id, lambda {
    {
      :include => { :item_belongs => { :item => [:evaluation_category, :evaluation_item]} },
      :order => 'items.evaluation_category_id, item_belongs.seq',
    }
  }

  scope :order_by_name, lambda {
    {
      :order => 'item_groups.name',
    }
  }

  def duplicate
    new_self = self.class.new attributes
    item_belongs.each do |item_belong|
      attrs = item_belong.attributes
      attrs.delete 'item_group_id'
      new_self.item_belongs << ItemBelong.new(attrs)
    end
    new_self
  end
end
