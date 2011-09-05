# -*- coding: utf-8 -*-
class IncompletesController < ApplicationController
  before_filter :login_required

  def index
    respond_to do |format|
      format.html {
        @users = current_user.incomplete_users
        render # index.html.erb
      }
      format.csv {
        csv = User.incompletes_to_csv(*current_user.incomplete_users)
        filename = I18n.t('filename_unevaluated_item_checksheet')
        if request.env['HTTP_USER_AGENT'] and request.env['HTTP_USER_AGENT'].include?('Win')
          send_data csv.tosjis, :type => 'text/csv; charset=Shift_JIS', :filename => filename.tosjis
        else
          send_data csv, :type => 'text/csv; charset=Shift_JIS', :filename => filename
        end
      }
    end
  end

  def show
    @incompletes = User.incompletes params[:id]
    respond_to do |format|
      format.html { render } # show.html.erb
      format.xml  { render :xml => @incompletes }
    end
  end

end
