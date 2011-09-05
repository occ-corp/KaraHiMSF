# -*- coding: utf-8 -*-

class ItemGroupsController < ApplicationController
  layout 'settings'

  # GET /item_groups
  # GET /item_groups.xml
  def index
    @item_groups = ItemGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @item_groups }
    end
  end

  # GET /item_groups/1
  # GET /item_groups/1.xml
  def show
    @item_group = ItemGroup.order_by_evaluation_category_id.find(params[:item_group_id] || params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item_group }
    end
  end

  # GET /item_groups/new
  # GET /item_groups/new.xml
  def new
    if params[:id]
      @item_group = ItemGroup.order_by_evaluation_category_id.find(params[:id]).duplicate
    else
      @item_group = ItemGroup.new
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item_group }
    end
  end

  # GET /item_groups/1/edit
  def edit
    @item_group = ItemGroup.find(params[:id])
  end

  # POST /item_groups
  # POST /item_groups.xml
  def create
    @item_group = ItemGroup.new(params[:item_group])

    respond_to do |format|
      if @item_group.save
        format.html { redirect_to(item_groups_path, :notice => "ItemGroup was successfully created.") }
        format.xml  { render :xml => @item_group, :status => :created, :location => @item_group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /item_groups/1
  # PUT /item_groups/1.xml
  def update
    @item_group = ItemGroup.find(params[:id])

    respond_to do |format|
      if @item_group.update_attributes(params[:item_group])
        format.html { redirect_to(@item_group, :notice => I18n.t('saved_successfully')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /item_groups/1
  # DELETE /item_groups/1.xml
  def destroy
    @item_group = ItemGroup.find(params[:id])
    @item_group.destroy

    respond_to do |format|
      format.html { redirect_to(item_groups_url) }
      format.xml  { head :ok }
    end
  end
end
