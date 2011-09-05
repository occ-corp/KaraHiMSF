# -*- coding: utf-8 -*-

class Qualification < ActiveRecord::Base
  has_many :users
  has_many :items_qualifications

  validates_presence_of :name
end
