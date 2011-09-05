# -*- coding: utf-8 -*-

class Point < ActiveRecord::Base
  has_many :scores, :dependent => :destroy

  def self.default
    self.find_by_is_default(true)
  end
end
