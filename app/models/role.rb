# -*- coding: utf-8 -*-

class Role < ActiveRecord::Base
  has_many :roles_users, :dependent => :destroy
  has_many :users, :through => :roles_users
end
