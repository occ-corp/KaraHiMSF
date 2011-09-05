# -*- coding: utf-8 -*-
class InterviewsController < ApplicationController
  before_filter :login_required

  acts_as_sessionable :methods => [:index], :params => [:phrase, :pending_only, :page]

  PAGINATE_PER_PAGE = 50

  # GET /interviews.json
  def index
    if current_user.roles.admin?
      @object_users = User.all_evaluatees
    else
      @object_users = User.under_evaluation_tree(current_user.evaluation_trees.topdown_only.first)
    end

    if params[:uninterviewed_only]
      @object_users = @object_users.uninterviewed
    end

    @object_users = @object_users.scoped_by_phrase(params[:phrase]).paginate(:per_page => PAGINATE_PER_PAGE, :page => params[:page], :order => "users.kana")

    respond_to do |format|
      format.html               # index.html.erb
      format.xml  { render :xml => @object_users }
    end
  end

  # POST /interviews.json
  def create
    @interview = Interview.new(params[:interview])

    respond_to do |format|
      if @interview.save
        format.json  { render :json => @interview, :status => :created, :location => @interview }
      else
        format.json  { render :json => @interview.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /interviews/1.json
  def update
    @interview = Interview.find(params[:id])

    respond_to do |format|
      if @interview.update_attributes(params[:interview])
        format.json  { head :ok }
      else
        format.json  { render :json => @interview.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /interviews/1.json
  def update
    @interview = Interview.find(params[:id])

    respond_to do |format|
      if @interview.update_attributes(params[:interview])
        format.json  { head :ok }
      else
        format.json  { render :json => @interview.errors, :status => :unprocessable_entity }
      end
    end
  end

end
