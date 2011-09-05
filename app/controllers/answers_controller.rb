# -*- coding: utf-8 -*-
class AnswersController < ApplicationController
  before_filter :login_required

  # POST /user/answer.json (only response ajax request)
  def create
    @answer = Answer.new(params[:answer])

    respond_to do |format|
      if @answer.save
        format.html {  redirect_to(:back, :notice => I18n.t('saved_successfully')) }
      else
        format.html {  redirect_to(:back, :notice => I18n.t('save_failed')) }
      end
    end
  end

  # PUT /user/answer/1.json (only response ajax request)
  def update
    @answer = Answer.find(params[:id])
    respond_to do |format|
      if @answer.update_attributes(params[:answer])
        format.html { redirect_to(:back, :notice => I18n.t('saved_successfully')) }
      else
        format.html { redirect_to(:back, :notice => I18n.t('save_failed')) }
      end
    end
  end
end
