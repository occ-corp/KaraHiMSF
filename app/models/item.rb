# -*- coding: utf-8 -*-

class Item < ActiveRecord::Base
  belongs_to :evaluation_item
  belongs_to :evaluation_category

  has_many :items_qualifications
  has_many :qualifications, :through => :items_qualifications

  has_many :item_belongs
  has_many :item_groups, :through => :item_belongs

  validates_presence_of :evaluation_category, :evaluation_item
  validates_uniqueness_of :evaluation_item_id, :scope => :evaluation_category_id

  attr_accessible :evaluation_item, :evaluation_category

  scope :order_by_evaluation_category_id, lambda {
    {
      :order => 'items.evaluation_category_id, items.evaluation_item_id'
    }
  }

  def name
    "(%s) %s" % [evaluation_category.name, evaluation_item.name]
  end
end
