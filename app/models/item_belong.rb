# -*- coding: utf-8 -*-

class ItemBelong < ActiveRecord::Base
  belongs_to :item
  belongs_to :item_group

  has_many :scores, :dependent => :destroy

  validates_presence_of :item, :seq
  validates_uniqueness_of :item_id, :scope => :item_group_id
  validates_uniqueness_of :seq, :scope => :item_group_id

  attr_accessible :item_group_id, :item_id, :weight, :seq, :note

  scope :scope_by_evaluation_category_and_order_by_evaluation_item, lambda { |*evaluation_category|
    {
      :include => { :item => [:evaluation_category, :evaluation_item] },
      :conditions => ['evaluation_categories.id in(?)', evaluation_category],
      :order => 'item_belongs.seq',
    }
  }
end
