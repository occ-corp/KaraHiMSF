# -*- coding: utf-8 -*-

class SettingsController < ApplicationController
  include ApplicationHelper

  def index
    redirect_to evaluation_trees_path
  end

end
