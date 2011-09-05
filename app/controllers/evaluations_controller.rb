# -*- coding: utf-8 -*-

class EvaluationsController < ApplicationController
  layout 'settings'

  before_filter :login_required

  PAGINATE_PER_PAGE = 10

  # GET /evaluations
  # GET /evaluations.xml
  def index
    default_params
    @users = User.
      scoped_by_division_full_set(params[:division_id]).
      scoped_by_phrase(params[:phrase]).
      paginate :page => params[:page],
               :order => 'users.name',
               :per_page => PAGINATE_PER_PAGE
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @evaluations }
    end
  end

  # GET /evaluations/1
  # GET /evaluations/1.xml
  def show
    @user = User.find(params[:id])
    @evaluation_order = EvaluationOrder.find(params[:evaluation_order_id])

    respond_to do |format|
      if request.xhr?
        format.html { render :layout => false } # show.html.erb
      else
        format.html { render :layout => 'evaluations' } # show.html.erb
      end
      format.xml  { render :xml => @user }
    end
  end

  # GET /evaluations/new
  # GET /evaluations/new.xml
  def new
    @evaluation = Evaluation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @evaluation }
    end
  end

  # GET /evaluations/1/edit
  def edit
    @user = User.find params[:id]
    @user.instance_eval <<-EOV
      alias :original_evaluations :evaluations
      def evaluations
        original_evaluations.scoped_by_evaluation_order_id(#{params[:evaluation_order_id]})
      end
    EOV

    render :layout => 'evaluations'
  end

  # POST /evaluations
  # POST /evaluations.xml
  def create
    @evaluation = Evaluation.new(params[:evaluation])

    respond_to do |format|
      if @evaluation.save
        flash[:notice] = 'Evaluation was successfully created.'
        format.html { redirect_to(@evaluation) }
        format.xml  { render :xml => @evaluation, :status => :created, :location => @evaluation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @evaluation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /evaluations/1
  # PUT /evaluations/1.xml
  def update
    params_to_update!

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = I18n.t('saved_successfully_and_close_the_window')
        format.html { redirect_to(:action => :edit, :id => @user, :evaluation_order_id => params[:evaluation_order_id]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /evaluations/1
  # DELETE /evaluations/1.xml
  def destroy
    @evaluation = Evaluation.find(params[:id])
    @evaluation.destroy

    respond_to do |format|
      format.html { redirect_to(evaluations_url) }
      format.xml  { head :ok }
    end
  end

  private

  def default_params
    params[:division_id] ||= Division.root
  end

  def params_to_update!
    @user = User.find(params[:id])
    evaluation_order = EvaluationOrder.find(params[:evaluation_order_id])

    params[:user] ||= { }
    params[:user][:evaluations_attributes] ||= { }

    evaluation_ids = params[:user][:evaluations_attributes].collect { |k, attrs|
      attrs[:id].to_i
    }
    max = params[:user][:evaluations_attributes].collect { |k, attr|
      k.to_i
    }.max || 0

    @user.evaluations.scoped_by_evaluation_order_id(evaluation_order).each do |evaluation|
      unless evaluation_ids.include?(evaluation.id)
        params[:user][:evaluations_attributes][max += 1] = {
          :id => evaluation.id,
          :_delete => true
        }
      end
    end
  end
end
