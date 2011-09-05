# -*- coding: utf-8 -*-

class EvaluationOrdersController < ApplicationController
  # GET /evaluation_orders
  # GET /evaluation_orders.xml
  def index
    @evaluation_orders = EvaluationOrder.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @evaluation_orders }
    end
  end

  # GET /evaluation_orders/1
  # GET /evaluation_orders/1.xml
  def show
    @evaluation_order = EvaluationOrder.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @evaluation_order }
    end
  end

  # GET /evaluation_orders/new
  # GET /evaluation_orders/new.xml
  def new
    @evaluation_order = EvaluationOrder.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @evaluation_order }
    end
  end

  # GET /evaluation_orders/1/edit
  def edit
    @evaluation_order = EvaluationOrder.find(params[:id])
  end

  # POST /evaluation_orders
  # POST /evaluation_orders.xml
  def create
    @evaluation_order = EvaluationOrder.new(params[:evaluation_order])

    respond_to do |format|
      if @evaluation_order.save
        flash[:notice] = 'EvaluationOrder was successfully created.'
        format.html { redirect_to(@evaluation_order) }
        format.xml  { render :xml => @evaluation_order, :status => :created, :location => @evaluation_order }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @evaluation_order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /evaluation_orders/1
  # PUT /evaluation_orders/1.xml
  def update
    @evaluation_order = EvaluationOrder.find(params[:id])

    respond_to do |format|
      if @evaluation_order.update_attributes(params[:evaluation_order])
        flash[:notice] = 'EvaluationOrder was successfully updated.'
        format.html { redirect_to(@evaluation_order) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @evaluation_order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /evaluation_orders/1
  # DELETE /evaluation_orders/1.xml
  def destroy
    @evaluation_order = EvaluationOrder.find(params[:id])
    @evaluation_order.destroy

    respond_to do |format|
      format.html { redirect_to(evaluation_orders_url) }
      format.xml  { head :ok }
    end
  end
end
