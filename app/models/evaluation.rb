# -*- coding: utf-8 -*-

class Evaluation < ActiveRecord::Base
  belongs_to :user
  belongs_to :object_user,
             :foreign_key => 'object_user_id',
             :class_name => 'User'
  belongs_to :evaluation_order
  has_many :scores, :dependent => :destroy
  accepts_nested_attributes_for :scores

  has_one :interview

  validates_presence_of :user, :object_user, :evaluation_order

  scope :scoped_by_evaluation_order_type, lambda { |evaluation_type|
    {
      :include => :evaluation_order,
      :conditions => ['evaluation_orders.type = ?', evaluation_type.to_s]
    }
  }

  scope :exclude_by_user, lambda { |user|
    {
      :conditions => ['evaluations.user_id <> ?', user]
    }
  }

  scope :only_matches_evaluation_orders, lambda { |*evaluation_orders|
    {
      :conditions => ['evaluations.evaluation_order_id in(?)', evaluation_orders]
    }
  }

  # http://coderrr.wordpress.com/2008/04/22/building-the-right-class-with-sti-in-rails/
  class << self
    def new_with_cast(*a, &b)
      if (h = a.first).is_a?(Hash) and
          (type = h[:type] || h['type']) and
          (klass = type.constantize) != self
        # klass should be a descendant of us
        raise "wtF hax!!"  unless klass < self
        return klass.new(*a, &b)
      end

      new_without_cast(*a, &b)
    end
    alias_method_chain :new, :cast
  end
end
