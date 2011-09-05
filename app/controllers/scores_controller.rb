# -*- coding: utf-8 -*-

class ScoresController < ApplicationController
  before_filter :login_required

  acts_as_sessionable :methods => [:index], :params => [:phrase, :only_unevaluated, :params, :evaluation_category_id, :user_id, :object_user_id], :init_params => lambda {
    params[:evaluation_category_id] ||= EvaluationCategory.first.id
    params[:user_id] ||= current_user.id
  }

  PAGINATE_PER_PAGE = 50

  # GET /scores
  # GET /scores.xml
  def index
    @user = current_user
    if request.xhr?
      evaluation_category = EvaluationCategory.find params[:evaluation_category_id]
      @evaluation_score_sheet = @user.build_evaluation_score_sheet params[:object_user_id], evaluation_category, !evaluation_category.is_a?(EvaluationCategory::Multifaceted)
      respond_to do |format|
        format.xml  { render :xml => @evaluation_score_sheet }
        format.json  {
          render :json => @evaluation_score_sheet
        }
      end
    else
      @evaluation_category = EvaluationCategory.find(params[:evaluation_category_id])
      @evaluation_type = @evaluation_category.class.evaluation_type
      if params[:only_unevaluated] == "true"
        object_users = current_user.object_users.
          scope_by_evaluation_order_type(@evaluation_type).
          scoped_by_phrase(params[:phrase]).
          only_unevaluated(@user, @evaluation_category).
          order_by_user_kana
      else
        object_users = current_user.object_users.
          scope_by_evaluation_order_type(@evaluation_type).
          scoped_by_phrase(params[:phrase]).
          order_by_user_kana
      end
      @object_users = User.paginate :per_page => PAGINATE_PER_PAGE,
                                    :page => params[:page],
                                    :conditions => ["users.id in(?)", object_users],
                                    :order => "users.kana"

      User.make_users_scores!(@object_users)

      unless @object_users.collect { |u| u.id }.include?(params[:object_user_id].to_i)
        params.delete :object_user_id
      end
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @scores }
      end
    end
  end

  # GET /scores/1
  # GET /scores/1.xml
  def show
    @score = Score.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @score }
    end
  end

  # GET /scores/new
  # GET /scores/new.xml
  def new
    @score = Score.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @score }
    end
  end

  # GET /scores/1/edit
  def edit
    @score = Score.find(params[:id])
  end

  # POST /scores
  # POST /scores.xml
  def create
    @score = Score.new(params[:score])

    respond_to do |format|
      if @score.save
        format.html { redirect_to(user_score_url(:id => @score, :user_id => params[:user_id]), :notice => 'Score was successfully created.') }
        format.xml  { render :xml => @score, :status => :created, :location => @score }
        format.json { render :json => @score.to_hash_for_json }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @score.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /scores/1
  # PUT /scores/1.xml
  def update
    @score = Score.find(params[:id])

    respond_to do |format|
      if @score.update_attributes(params[:score])
        format.html { redirect_to(user_score_url(:id => @score, :user_id => params[:user_id]), :notice => 'Score was successfully updated.') }
        format.xml  { head :ok }
        format.json { render :json => @score.to_hash_for_json }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @score.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scores/1
  # DELETE /scores/1.xml
  def destroy
    @score = Score.find(params[:id])
    @score.destroy

    respond_to do |format|
      format.html { redirect_to(user_scores_url(:user_id => params[:user_id])) }
      format.xml  { head :ok }
    end
  end

end
