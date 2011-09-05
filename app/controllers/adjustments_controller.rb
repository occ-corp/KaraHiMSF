# -*- coding: utf-8 -*-
class AdjustmentsController < ApplicationController
  before_filter :login_required

  PAGINATE_PER_PAGE = 20

  # GET /adjustment
  def show
    restore_session
    if current_user.roles.admin?
      users = User.aggregate_each_user
    elsif current_user.roles.decider?
      users_under_evaluation_tree = User.under_evaluation_tree(current_user.evaluation_trees.topdown_only.first)
      if users_under_evaluation_tree.empty?
        users = []
      else
        users = User.aggregate_each_user(*users_under_evaluation_tree)
      end
    else
      users = []
    end
    rank = Rank.find_by_rank(params[:rank])
    if rank
      users = users.select do |user|
        rank.proc.call(user.adjusted_total) ? true : false
      end
    end
    user_id_map = users.inject({ }) do |hash, user|
      hash.merge({ user.id => user })
    end
    @users = User.scoped_by_phrase(params[:phrase]).paginate :conditions => ["users.id in(?)", users], :per_page => PAGINATE_PER_PAGE, :page => params[:page], :order=> "users.kana"
    @users.each do |user|
      user_has_score = user_id_map[user.id]
      user.instance_eval { @_user_has_score = user_has_score }
      def user.total
        @_user_has_score.total
      end
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # PUT /adjustment
  def update
    ActiveRecord::Base.transaction do
      if params[:adjustments]
        params[:adjustments].each do |n, attributes|
          if attributes[:id].to_s.empty?
            Adjustment.create! attributes
          else
            Adjustment.find(attributes[:id]).update_attributes! attributes
          end
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to(adjustment_path, :notice => I18n.t('saved_successfully')) }
    end
  rescue ActiveRecord::ActiveRecordError => e
    respond_to do |format|
      @users = User.under_evaluation_tree(current_user.evaluation_trees.topdown_only.first)
      format.html { render :action => "show" }
    end
  end

  private

  SESSION_PARAMS = [:rank, :phrase]

  def restore_session
    unless session.has_key?(:adjustments)
      session[:adjustments] = { }
      set_default_params
    end
    if params[:session_save] == "true"
      SESSION_PARAMS.each { |k| session[:adjustments][k] = params[k] }
    else
      SESSION_PARAMS.each do |k|
        if params[k].to_s.empty?
          params[k] = session[:adjustments][k]
        else
          session[:adjustments][k] = params[k]
        end
      end
    end
  end

  def set_default_params
  end
end
