# -*- coding: utf-8 -*-

class EvaluationOrder < ActiveRecord::Base
  belongs_to :evaluation_group
  has_many :evaluations
  has_many :evaluation_trees

  attr_accessible :evaluation_group
end
