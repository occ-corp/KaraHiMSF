# -*- coding: utf-8 -*-

class JobTitlesController < ApplicationController
  layout 'settings'

  before_filter :login_required

  # GET /job_titles
  # GET /job_titles.xml
  def index
    @job_titles = JobTitle.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @job_titles }
    end
  end

  # GET /job_titles/1
  # GET /job_titles/1.xml
  def show
    @job_title = JobTitle.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @job_title }
    end
  end

  # GET /job_titles/new
  # GET /job_titles/new.xml
  def new
    @job_title = JobTitle.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @job_title }
    end
  end

  # GET /job_titles/1/edit
  def edit
    @job_title = JobTitle.find(params[:id])
  end

  # POST /job_titles
  # POST /job_titles.xml
  def create
    @job_title = JobTitle.new(params[:job_title])

    respond_to do |format|
      if @job_title.save
        flash[:notice] = 'JobTitle was successfully created.'
        format.html { redirect_to(@job_title) }
        format.xml  { render :xml => @job_title, :status => :created, :location => @job_title }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @job_title.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /job_titles/1
  # PUT /job_titles/1.xml
  def update
    @job_title = JobTitle.find(params[:id])

    respond_to do |format|
      if @job_title.update_attributes(params[:job_title])
        flash[:notice] = 'JobTitle was successfully updated.'
        format.html { redirect_to(@job_title) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @job_title.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /job_titles/1
  # DELETE /job_titles/1.xml
  def destroy
    @job_title = JobTitle.find(params[:id])
    @job_title.destroy

    respond_to do |format|
      format.html { redirect_to(job_titles_url) }
      format.xml  { head :ok }
    end
  end
end
