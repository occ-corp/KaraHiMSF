# -*- coding: utf-8 -*-

class RolesUser < ActiveRecord::Base
  belongs_to :role
  belongs_to :user
end
