# -*- coding: utf-8 -*-

class ItemBelongsController < ApplicationController
  layout 'settings'

  before_filter :login_required

  # GET /item_belongs
  # GET /item_belongs.xml
  def index
    @item_belongs = ItemBelong.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @item_belongs }
    end
  end

  # GET /item_belongs/1
  # GET /item_belongs/1.xml
  def show
    @item_belong = ItemBelong.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item_belong }
    end
  end

  # GET /item_belongs/new
  # GET /item_belongs/new.xml
  def new
    @item_belong = ItemBelong.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item_belong }
    end
  end

  # GET /item_belongs/1/edit
  def edit
    @item_belong = ItemBelong.find(params[:id])
  end

  # POST /item_belongs
  # POST /item_belongs.xml
  def create
    @item_belong = ItemBelong.new(params[:item_belong])

    respond_to do |format|
      if @item_belong.save
        flash[:notice] = 'ItemBelong was successfully created.'
        format.html { redirect_to(@item_belong) }
        format.xml  { render :xml => @item_belong, :status => :created, :location => @item_belong }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item_belong.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /item_belongs/1
  # PUT /item_belongs/1.xml
  def update
    @item_belong = ItemBelong.find(params[:id])

    respond_to do |format|
      if @item_belong.update_attributes(params[:item_belong])
        flash[:notice] = 'ItemBelong was successfully updated.'
        format.html { redirect_to(@item_belong) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item_belong.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /item_belongs/1
  # DELETE /item_belongs/1.xml
  def destroy
    @item_belong = ItemBelong.find(params[:id])
    @item_belong.destroy

    respond_to do |format|
      format.html { redirect_to(item_belongs_url) }
      format.xml  { head :ok }
    end
  end
end
