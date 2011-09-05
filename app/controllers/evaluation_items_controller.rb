# -*- coding: utf-8 -*-

class EvaluationItemsController < ApplicationController
  # GET /evaluation_items
  # GET /evaluation_items.xml
  def index
    @evaluation_items = EvaluationItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @evaluation_items }
    end
  end

  # GET /evaluation_items/1
  # GET /evaluation_items/1.xml
  def show
    @evaluation_item = EvaluationItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @evaluation_item }
    end
  end

  # GET /evaluation_items/new
  # GET /evaluation_items/new.xml
  def new
    @evaluation_item = EvaluationItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @evaluation_item }
    end
  end

  # GET /evaluation_items/1/edit
  def edit
    @evaluation_item = EvaluationItem.find(params[:id])
  end

  # POST /evaluation_items
  # POST /evaluation_items.xml
  def create
    @evaluation_item = EvaluationItem.new(params[:evaluation_item])

    respond_to do |format|
      if @evaluation_item.save
        flash[:notice] = 'EvaluationItem was successfully created.'
        format.html { redirect_to(@evaluation_item) }
        format.xml  { render :xml => @evaluation_item, :status => :created, :location => @evaluation_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @evaluation_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /evaluation_items/1
  # PUT /evaluation_items/1.xml
  def update
    @evaluation_item = EvaluationItem.find(params[:id])

    respond_to do |format|
      if @evaluation_item.update_attributes(params[:evaluation_item])
        flash[:notice] = 'EvaluationItem was successfully updated.'
        format.html { redirect_to(@evaluation_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @evaluation_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /evaluation_items/1
  # DELETE /evaluation_items/1.xml
  def destroy
    @evaluation_item = EvaluationItem.find(params[:id])
    @evaluation_item.destroy

    respond_to do |format|
      format.html { redirect_to(evaluation_items_url) }
      format.xml  { head :ok }
    end
  end
end
