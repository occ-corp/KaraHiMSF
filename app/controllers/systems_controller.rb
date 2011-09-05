# -*- coding: utf-8 -*-

class SystemsController < ApplicationController
  layout 'settings'

  before_filter :login_required

  # GET /systems
  # GET /systems.xml
  def index
    @system = System.system

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @system }
    end
  end

  # GET /systems/1/edit
  def edit
    @system = System.find(params[:id])
  end

  # PUT /systems/1
  # PUT /systems/1.xml
  def update
    @system = System.find(params[:id])

    respond_to do |format|
      if @system.update_attributes(params[:system])
        flash[:notice] = 'System was successfully updated.'
        format.html { redirect_to :action => :index }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @system.errors, :status => :unprocessable_entity }
      end
    end
  end
end
