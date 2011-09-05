# -*- coding: utf-8 -*-

class ItemsQualification < ActiveRecord::Base
  belongs_to :qualification
  belongs_to :item
end
