# -*- coding: utf-8 -*-

class EvaluationCategory < ActiveRecord::Base
  belongs_to :evaluation_group
  has_many :items
  has_many :evaluation_items, :through => :items

  attr_accessible :evaluation_group

  scope :with_evaluation_items_scoped_by_user, lambda { |user|
    {
      :include => { :items => [:evaluation_item, { :items_qualifications => :qualification}, { :item_belongs => { :item_group => :users}}]},
      :conditions => ['users.id = ? and qualifications.id = users.qualification_id', user],
      :order => 'item_belongs.seq'
    }
  }

  def self.evaluation_item_map_by_user(user)
    categories = with_evaluation_items_scoped_by_user(user)
    scores_by_evaluation_item = user.evaluation_item_score_map
    topdown_evaluation_orders = EvaluationOrder::TopDown.all
    max_point = Point.maximum :point
    categories.inject({ }) do |map, category|
      category.items.each do |item|
        evaluation_item = item.evaluation_item
        scores_by_evaluation_order_id = scores_by_evaluation_item[evaluation_item.id]
        item_weight = item.item_belongs.first.weight
        qualification_weight = item.items_qualifications.first.weight
        evaluation_item.instance_eval <<-EOV
          def item_weight
            #{item_weight}
          end
          def qualification_weight
            #{qualification_weight}
          end
          def score_by_evaluation_order_id(evaluation_order_id)
            {
              #{scores_by_evaluation_order_id ? scores_by_evaluation_order_id.collect { |t| "%d => %f" % [t.first, t.last] }.join(',') : nil}
            }[evaluation_order_id]
          end
          def topdown_evaluation_score
            #{scores_by_evaluation_order_id ? topdown_evaluation_orders.inject(0) {|acc, order| acc += scores_by_evaluation_order_id[order.id].to_f * order.weight} * item_weight * qualification_weight : 0.0}
          end
          def topdown_evaluation_max_point
            #{topdown_evaluation_orders.inject(0) {|acc, order| acc += max_point.to_f * order.weight} * item_weight}
          end
        EOV
        map[category] ||= []
        map[category] << evaluation_item
      end
      map
    end
  end

  def self.evaluation_type
    Evaluation
  end
end
