# -*- coding: utf-8 -*-

class BelongsController < ApplicationController
  layout 'settings'

  before_filter :login_required

  PAGINATE_PER_PAGE = 5

  # GET /items
  # GET /items.xml
  def index
      session[:belongs] ||= { }

      restore_session

      @divisions = division_paginate

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @items }
      end
  end

  # GET /items/1
  # GET /items/1.xml
  def show
    @divisions = division_paginate

    respond_to do |format|
      format.html { render :action => :index } # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  # GET /items/new
  # GET /items/new.xml
  def new
    @item = Item.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
  end

  # POST /items
  # POST /items.xml
  def create
    @item = Item.new(params[:item])

    respond_to do |format|
      if @item.save
        flash[:notice] = 'Item was successfully created.'
        format.html { redirect_to(@item) }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    ActiveRecord::Base.transaction do
      params[:divisions].each do |k, division_attrs|
        Division.find(division_attrs.delete(:id)).update_attributes!(division_attrs)
      end
    end
    respond_to do |format|
      flash[:notice] = I18n.t('saved_successfully')
      format.html { redirect_to(belongs_url) }
      format.xml  { head :ok }
    end
  rescue => e
    respond_to do |format|
      flash[:notice] = I18n.t('save_failed_by_some_issues')
      format.html { redirect_to(belongs_url) }
      format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
    end
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to(items_url) }
      format.xml  { head :ok }
    end
  end

  private

  def division_paginate
    Division.paginate :conditions => cond_for_division_id(params[:id]),
                      :include => { :belongs => :user},
                      :per_page => PAGINATE_PER_PAGE,
                      :page => params[:page],
                      :order => Division.order_for_organizing + ', users.kana'
  end

  def cond_for_division_id(division_id)
    unless division_id.to_s.empty?
      division = Division.find(division_id)
      ['divisions.lft between ? and ?', division.lft, division.rgt]
    end
  end

  def restore_session
    if params[:id]
      session[:belongs][:id] = params[:id]
    else
      params[:id] = session[:belongs][:id]
    end
    if params[:page]
      session[:belongs][:page] = params[:page]
    else
      params[:page] = session[:belongs][:page]
    end
  end
end
