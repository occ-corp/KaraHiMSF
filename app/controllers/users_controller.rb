# -*- coding: utf-8 -*-

class UsersController < ApplicationController
  layout 'settings'

  before_filter :login_required

  PAGINATE_PER_PAGE = 20

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include ApplicationHelper

  def index
    respond_to do |format|
      format.html {
        session[:users] ||= { }
        restore_session
        @users = User.
          scoped_by_division_full_set(params[:division_id]).
          scoped_by_phrase(params[:phrase]).
          paginate :per_page => PAGINATE_PER_PAGE,
                   :page => params[:page],
                   :order => 'users.kana'
        render
      }
      format.xml {
        common_for_ajax_request
        render :xml => @users
      }
      format.json {
        common_for_ajax_request
        render :json => @users
      }
    end
  end

  # render new.rhtml
  def new
    @user = User.new
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def update
    ActiveRecord::Base.transaction do
      params[:users].each do |k, user_attrs|
        User.find(user_attrs.delete(:id)).update_attributes!(user_attrs)
      end
    end
    respond_to do |format|
      flash[:notice] = I18n.t('saved_successfully')
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      flash[:notice] = I18n.t('save_failed_by_some_issues')
      format.html { redirect_to(users_url) }
      format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
    end
  end

  # GET /usrs/results.pdf
  # GET /usrs/results.csv
  def results
    if params[:format] == "pdf"
      if current_user.roles.decider? or current_user.has_topdown_evaluations?
        @object_users = User.under_division_tree_full_set(*current_user.divisions)
      else
        @object_users = []
      end
      if System.evaluation_published_employees?
        if !@object_users.include?(current_user)
          @object_users << current_user
        end
      else
        @object_users.delete_if { |object_user| object_user == current_user }
      end
      User.make_users_scores!(@object_users)
      begin
        tempfile = Tempfile.new "evaluation_results_generated_by_#{current_user.login}"
        path = tempfile.path
        tempfile.close true
        PdfExporter.evaluation_results path, @object_users.to_custom_hash
        filename = I18n.t('filename_result_pdf')
        if request.env['HTTP_USER_AGENT'] and request.env['HTTP_USER_AGENT'].include?('Win')
          send_file path, :filename => filename.tosjis, :type => "application/pdf"
        else
          send_file path, :filename => filename, :type => "application/pdf"
        end
        begin
          File.delete(path)
        rescue Errno::ENOENT
        end
      rescue => e
        if defined?(path)
          begin
            File.delete(path)
          rescue Errno::ENOENT
          end
        end
        raise e
      end
    elsif params[:format] == "csv"
      if current_user.roles.admin?
        @object_users = User.includes(:divisions, :adjustment, :qualification, :job_titles).order("users.kana")
      else
        if current_user.roles.decider? or current_user.has_topdown_evaluations?
          @object_users = User.includes(:divisions, :adjustment, :qualification, :job_titles).order("users.kana").under_division_tree_full_set(*current_user.divisions)
        end
        if System.evaluation_published_employees?
          if !@object_users.include?(current_user)
            @object_users << current_user
          end
        else
          @object_users.delete_if { |object_user| object_user == current_user }
        end
      end
      User.make_users_scores!(@object_users)
      filename = I18n.t('filename_eval_result_list')
      if request.env['HTTP_USER_AGENT'] and request.env['HTTP_USER_AGENT'].include?('Win')
        send_data @object_users.to_csv.tosjis, :type => 'text/csv; charset=Shift_JIS', :filename => filename.tosjis
      else
        send_data @object_users.to_csv, :type => 'text/csv; charset=Shift_JIS', :filename => filename
      end
    end
  end

  def result
    respond_to do |format|
      format.json do
        @user = User.find params[:user_id]
        User.make_users_scores!([@user])
        render(:json => {
                 :total_multifaceted_evaluation => @user.scores.total_multifaceted_evaluation.to_s,
                 :total_first_topdown_evaluation => @user.scores.total_first_topdown_evaluation.to_s,
                 :total_first_topdown_plus_multifaceted => (@user.scores.total_first_topdown_evaluation + @user.scores.total_multifaceted_evaluation).to_s,
                 :total_first_topdown_plus_multifaceted_rank => Rank.find_by_score(@user.scores.total_first_topdown_evaluation + @user.scores.total_multifaceted_evaluation).name,
                 :total_second_topdown_evaluation => @user.scores.total_second_topdown_evaluation.to_s,
                 :total_second_topdown_plus_multifaceted => (@user.scores.total_second_topdown_evaluation + @user.scores.total_multifaceted_evaluation).to_s,
                 :total_second_topdown_plus_multifaceted_rank => Rank.find_by_score(@user.scores.total_second_topdown_evaluation + @user.scores.total_multifaceted_evaluation).name,
               }.to_json)
      end
      format.html do
        evaluation_accessible = true
        if params[:id]
          evaluation_accessible = false
          @user = User.make_users_scores!([User.find(params[:id])]).first

          if current_user.roles.admin?
            evaluation_accessible = true
          end

          if System.evaluation_published_managers?
            if current_user.roles.decider?
              if User.under_division_tree_full_set(*current_user.divisions).include?(@user)
                evaluation_accessible = true
              end
            else
              if User.under_division_tree(*current_user.divisions).include?(@user)
                evaluation_accessible = true
              end
            end
          end

          if System.evaluation_published_employees?
            if @user == current_user
              evaluation_accessible = true
            end
          end
        end
        if evaluation_accessible
          if @user
            @evaluation_item_map = @user.evaluation_item_map
          else
            @evaluation_item_map = { }
          end
          render :layout => 'application' # result.html.erb
        else
          render :layout => 'application', :text => <<-EOS
            <div class="flash" style="margin-top:10px">
                <div class="message error">
                  <p><%= I18n.t('access_denied') %></p>
                </div>
            </div>
          EOS
        end
      end
    end
  end

  def incompletes
    respond_to do |format|
      format.html
      format.csv {
        filename = I18n.t('filename_unevaluated_item_checksheet')
        if request.env['HTTP_USER_AGENT'] and request.env['HTTP_USER_AGENT'].include?('Win')
          send_data User.incompletes_to_csv.tosjis, :type => 'text/csv; charset=Shift_JIS', :filename => filename.tosjis
        else
          send_data User.incompletes_to_csv, :type => 'text/csv; charset=Shift_JIS', :filename => filename
        end
      }
    end
  end

  private

  def common_for_ajax_request
    @users = User.
      scoped_by_division_full_set(params[:division_id]).
      scoped_by_phrase(params[:phrase])
    User.set_long_name! @users
  end

  def restore_session
    if params[:division_id]
      session[:users][:division_id] = params[:division_id]
    else
      params[:division_id] = session[:users][:division_id]
    end
    if params[:phrase]
      session[:users][:phrase] = params[:phrase]
    else
      params[:phrase] = session[:users][:phrase]
    end
    if params[:page]
      session[:users][:page] = params[:page]
    else
      params[:page] = session[:users][:page]
    end
  end
end
