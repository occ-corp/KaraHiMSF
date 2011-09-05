class EvaluationGroup < ActiveRecord::Base
  has_many :evaluation_orders, :class_name => "EvaluationOrder"
  has_many :evaluation_categories, :class_name => "EvaluationCategory"
end
