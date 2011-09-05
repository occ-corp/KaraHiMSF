# -*- coding: utf-8 -*-

class EvaluationItem < ActiveRecord::Base
  has_many :items
  has_many :evaluation_categories, :through => :items
end
