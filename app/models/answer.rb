# -*- coding: utf-8 -*-
class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

  validates_uniqueness_of :question_id, :scope => :user_id

  def self.default
    I18n.t('answer_no')
  end

  def show
    self.answer ? I18n.t('answer_yes') : I18n.t('answer_no')
  end
end
