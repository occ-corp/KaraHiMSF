# -*- coding: utf-8 -*-

class EvaluationCategoriesItem < ActiveRecord::Base
  belongs_to :evaluation_category
  belongs_to :item
end
