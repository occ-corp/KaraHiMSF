# -*- coding: utf-8 -*-
class EvaluationTreesController < ApplicationController
  layout 'settings'

  before_filter :login_required

  # GET /evaluation_trees
  # GET /evaluation_trees.xml
  def index
    restore_session
    @klass = find_evaluation_tree_class restore_params_type
    if request.xhr?
      if params[:flatten].to_s == "true"
        @evaluation_trees = @klass.
          order_by_user_kana.
          only_exactly_have_user.
          scope_by_phrase(params[:phrase]).
          disabled_only(params[:disabled_only], JSON.parse(params[:pending_disablings].to_s)).
           without_excluded(params[:with_excluded]).
          paginate :include => :user, :per_page => 15, :page => params[:page]
        respond_to do |format|
          format.json {
            render :json => {
              :evaluation_trees => @evaluation_trees.collect {|t| t.to_hash_for_json},
              :pages => {
                :previous_page => @evaluation_trees.previous_page,
                :next_page => @evaluation_trees.next_page,
              },
            }
          }
        end
      else
        respond_to do |format|
          format.json do
            render :json => @klass.to_sexpr { |t| t.to_hash_for_json }
          end
        end
      end
    else
      respond_to do |format|
        if current_user.roles.admin?
          params[:editing_enabled] = true
        end
        format.html # index.html.erb
        format.csv do
          filename = I18n.t(:filename_group_list, :description => @klass.description)
          if request.env['HTTP_USER_AGENT'] and request.env['HTTP_USER_AGENT'].include?('Win')
            send_data @klass.to_csv(params[:field], current_user.roles.admin?).tosjis, :type => 'text/csv', :filename => filename.tosjis
          else
            send_data @klass.to_csv(params[:field], current_user.roles.admin?), :type => 'text/csv', :filename => filename
          end
        end
      end
    end
  end

  def csv_import
    @klass = find_evaluation_tree_class restore_params_type
    respond_to do |format|
      format.html # csv_import.html.erb
    end
  end

  # GET /evaluation_trees/1
  # GET /evaluation_trees/1.xml
  def show
    @evaluation_tree = EvaluationTree.find_by_id params[:id]
    if @evaluation_tree
      if params[:recursively].to_s == 'true'
        if params[:flatten].to_s == 'true'
          respond_to do |format|
            format.json  {
              render :json => @evaluation_tree.all_children.collect { |child|
                { :id => child.id }
              }
            }
          end
        end
      elsif params[:path].to_s == 'true'
        respond_to do |format|
          format.json  {
            render :json => @evaluation_tree.to_sexpr_path { |t|
              { :id => t.id }
            }
          }
        end
      else
        respond_to do |format|
          format.json  {
            render :json => @evaluation_tree.children(:include => :user, :order => "users.kana").collect { |child|
              child.to_sexpr { |t|
                t.to_hash_for_json
              }
            }
          }
        end
      end
    else
      respond_to do |format|
        format.json { head :ok }
      end
    end
  end

  # GET /evaluation_trees/new
  # GET /evaluation_trees/new.xml
  def new
    @evaluation_tree = EvaluationTree.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @evaluation_tree }
    end
  end

  # GET /evaluation_trees/1/edit
  def edit
    @evaluation_tree = EvaluationTree.find(params[:id])
  end

  # POST /evaluation_trees
  # POST /evaluation_trees.xml
  def create
    klass = find_evaluation_tree_class params[:type]

    @evaluation_tree = klass.new(params[:evaluation_tree])

    respond_to do |format|
      if @evaluation_tree.save
        format.html { redirect_to(@evaluation_tree, :notice => 'Evaluation tree was successfully created.') }
        format.xml  { render :xml => @evaluation_tree, :status => :created, :location => @evaluation_tree }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @evaluation_tree.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /evaluation_trees/0.json
  # PUT /evaluation_trees/1.json
  def update
    ActiveRecord::Base.transaction do
      if params[:id] == "0"
        @klass = find_evaluation_tree_class restore_params_type
        if params[:file]
          # params[:evaluation_trees] = build_evaluation_tree_from_csv.to_json
          # params[:deleted_evaluation_trees] = build_deletings.to_json

          build_evaluation_tree_from_csv

        end
        confirm_or_update
        respond_to do |format|
          format.html { redirect_to(evaluation_trees_path, :notice => I18n.t('updated_successfully')) }
          format.xml  { head :ok }
        end
      else
        klass = find_evaluation_tree_class params[:type]
        @evaluation_tree = klass.find params[:id]
        if params[:evaluation_tree] and params[:evaluation_tree][:user] and params[:evaluation_tree][:user][:excluded]
          params[:evaluation_tree][:user][:excluded] = false
        end
        respond_to do |format|
          if @evaluation_tree.update_attributes(params[:evaluation_tree])
            format.json  { head :ok }
          else
            format.json  { render :json => @evaluation_tree.errors, :status => :unprocessable_entity }
          end
        end
      end
    end
  end

  def confirm
    @klass = find_evaluation_tree_class restore_params_type
    ActiveRecord::Base.transaction do
      confirm_or_update true
      raise ActiveRecord::RecordNotSaved
    end
  rescue ActiveRecord::RecordNotSaved
    respond_to do |format|
      format.html { render :partial => 'confirm', :status => :unprocessable_entity }
    end
  end

  private

  def restore_session
    session[:evaluation_trees] ||= { }

    if params[:division_id]
      session[:evaluation_trees][:division_id] = params[:division_id]
    else
      params[:division_id] = session[:evaluation_trees][:division_id]
    end
    if params[:phrase]
      session[:evaluation_trees][:phrase] = params[:phrase]
    else
      params[:phrase] = session[:evaluation_trees][:phrase]
    end
    if params[:page]
      session[:evaluation_trees][:page] = params[:page]
    else
      params[:page] = session[:evaluation_trees][:page]
    end
    if params[:disabled_only]
      session[:evaluation_trees][:disabled_only] = params[:disabled_only]
    else
      params[:disabled_only] = session[:evaluation_trees][:disabled_only]
    end
    if params[:with_excluded]
      session[:evaluation_trees][:with_excluded] = params[:with_excluded]
    else
      params[:with_excluded] = session[:evaluation_trees][:with_excluded]
    end
  end

  def restore_params_type
    if params[:type]
      session[:evaluation_trees][:type] = params[:type]
    else
      params[:type] = session[:evaluation_trees][:type]
    end
    params[:type] ||= EvaluationTree::TopDown.to_s.downcase
  end

  def find_evaluation_tree_class(t)
    if t == EvaluationTree::TopDown.to_s.downcase
      EvaluationTree::TopDown
    elsif t == EvaluationTree::Multifaceted.to_s.downcase
      EvaluationTree::Multifaceted
    else
      raise ArgumentError.new("No specified params[:type]")
    end
  end

  class FooError < ActiveRecord::ActiveRecordError
  end

  def confirm_or_update(confirm=false)
    begin
      ActiveRecord::Base.transaction do
        evaluation_orders = @klass.evaluation_order_class.all

        @evaluations = []

        callbacks = {
          :added => lambda { |current, parent, brothers, real_parent, current_children|
            original_parent = current.parent
            if !original_parent and current.respond_to?(:original_parent)
              original_parent = current.original_parent
            end
            original_parent_parent = current.parent ? current.parent.parent : nil
            if !original_parent_parent and current.respond_to?(:original_parent_parent)
              original_parent_parent = current.original_parent_parent
            end
            # if confirm
            #   current.instance_eval do
            #     @_parent = parent
            #     def parent
            #       @_parent
            #     end
            #   end
            # else
              if current.new_record?
                current.save!
              end
              if parent
                current.move_to_child_of parent
              end
            # end
            evaluation_orders.each do |evaluation_order|
              if evaluation_order.is_a?(EvaluationOrder::TopDown)
                do_it = true

                if evaluation_order.name == I18n.t('second_eval') and current and current.parent and current.parent and original_parent != parent and current.parent.parent and current.parent.parent == original_parent_parent
                  do_it = false
                end

                if evaluation_order.name == I18n.t('second_eval') and parent.parent
                  parent = parent.parent
                end
                if do_it
                  e = Evaluation.new :evaluation_order => evaluation_order,
                  :user => parent.user,
                  :object_user => current.user
                  # if confirm
                  #   add_fake_methods e, parent.user, current.user
                  #   @evaluations << e
                  # else
                    def e.modification; :created; end
                    e.save!
                    @evaluations << e
                  # end
                end
              elsif evaluation_order.is_a?(EvaluationOrder::Multifaceted)
                if !current.group? and parent and brothers.count > 1
                  e = Evaluation.new :evaluation_order => evaluation_order,
                  :user => current.user,
                  :object_user => parent.user
                  # if confirm
                  #   add_fake_methods e, current.user, parent.user
                  #   @evaluations << e
                  # else
                    def e.modification; :created; end
                    e.save!
                    @evaluations << e
                  # end
                  # unless parent.user.has_self_evaluation?
                  #   e = Evaluation.new :evaluation_order => evaluation_order,
                  #   :user => parent.user,
                  #   :object_user => parent.user
                  #   def e.modification; :created; end
                  #   e.save!
                  #   @evaluations << e
                  # end
                end
                if !current.group? and real_parent and !real_parent.user.has_self_evaluation? and brothers.count > 1

                    e = Evaluation.new :evaluation_order => evaluation_order,
                    :user => real_parent.user,
                    :object_user => real_parent.user
                    def e.modification; :created; end
                    e.save!
                    @evaluations << e

                # elsif real_parent and !real_parent.user.has_self_evaluation?
                #   e = Evaluation.new :evaluation_order => evaluation_order,
                #   :user => real_parent.user,
                #   :object_user => real_parent.user
                #   def e.modification; :created; end
                #   e.save!
                  #   @evaluations << e
                elsif current.group? and real_parent and !real_parent.user.has_self_evaluation?
                  followers = EvaluationTree.find_all_by_id((current_children || []).flatten).collect {|e| e.user ? e.user.id : nil}.compact
                  if followers.count > 1
                    e = Evaluation.new :evaluation_order => evaluation_order,
                    :user => real_parent.user,
                    :object_user => real_parent.user
                    def e.modification; :created; end
                    e.save!
                    @evaluations << e
                  end
                end
              end
            end
          },
          :removed => lambda { |current, parent|
            original_parent = current.parent
            while original_parent and original_parent.group?
              original_parent = original_parent.parent
            end
            original_parent_parent = current.parent ? current.parent.parent : nil
            while original_parent_parent and original_parent_parent.group?
              original_parent_parent = original_parent_parent.parent
            end
            # if confirm
            #   #
            # else
              current.update_attribute :selected, false
              current.move_root
            # end
            evaluation_orders.each do |evaluation_order|
              if evaluation_order.is_a?(EvaluationOrder::TopDown)
                do_it = true
                if evaluation_order.name == I18n.t('second_eval') and current and original_parent != parent and parent and original_parent_parent and original_parent_parent == parent.parent
                  do_it = false
                end
                if do_it
                  evaluations = Evaluation.find :all,
                  :conditions => [<<-EOS, evaluation_order, current.user
                                    evaluations.evaluation_order_id = ?
                                    and evaluations.object_user_id = ?
                                  EOS
                                 ]
                  # if confirm
                    evaluations.each do |e|
                      def e.modification
                        :destroyed
                      end
                    end
                  #   @evaluations.concat(evaluations)
                  # else
                    evaluations.each { |e| e.destroy }
                    @evaluations.concat(evaluations)
                  # end
                end
              elsif evaluation_order.is_a?(EvaluationOrder::Multifaceted)
                evaluations = Evaluation.find :all,
                :include => [:user, :object_user],
                :conditions => [<<-EOS, evaluation_order, current.user, current.user
                                  evaluations.evaluation_order_id = ?
                                  and (evaluations.user_id = ? or
                                       evaluations.object_user_id = ?)
                                EOS
                               ]
                if original_parent
                  original_parent.reload
                  children = original_parent.children
                  count = 0
                  children.each do |child|
                    if child != current
                      count += 1
                    else
                      count += child.all_children_count(:conditions => "evaluation_trees.user_id is not null")
                    end
                  end
                  if count < 2
                    evaluations.concat(Evaluation.only_matches_evaluation_orders(evaluation_order).find_all_by_object_user_id(original_parent.user))
                  end
                end
                # if confirm
                  evaluations.each do |e|
                    def e.modification
                      :destroyed
                    end
                  end
                #   @evaluations.concat(evaluations)
                # else
                  evaluations.each { |e| e.destroy }
                  @evaluations.concat(evaluations)
                # end
              end
            end
            # if confirm
            #   true
            # else
              current.instance_eval do
                @_original_parent = original_parent
                def original_parent
                  @_original_parent
                end
                @_original_parent_parent = original_parent_parent
                def original_parent_parent
                  @_original_parent_parent
                end
              end
            # end
          },
          :move_to => lambda { |current, parent, original_real_parent, current_children|
            evaluation_orders.each do |evaluation_order|
              if evaluation_order.is_a?(EvaluationOrder::Multifaceted)
                if original_real_parent
                  original_parent = original_real_parent
                else
                  original_parent = current.parent
                  while original_parent and original_parent.group?
                    original_parent = original_parent.parent
                  end
                end
                # if confirm
                #   #
                # else
                  if current.new_record?
                    current.save!
                  end
                  if parent
                    current.move_to_child_of parent
                  else
                    current.move_root
                  end
                # end
                followers = EvaluationTree.find_all_by_id((current_children || []).flatten).collect {|e| e.user ? e.user.id : nil}.compact
                if followers.empty?
                  evaluations = Evaluation.find :all,
                  :include => [:user, :object_user],
                  :conditions => [<<-EOS, evaluation_order, current.user, current.user
                                    evaluations.evaluation_order_id = ?
                                    and (evaluations.user_id = ? or evaluations.object_user_id = ?)
                                  EOS
                                 ]
                else
                  evaluations = Evaluation.find :all,
                  :include => [:user, :object_user],
                  :conditions => [<<-EOS, {:evaluation_order => evaluation_order, :user => current.user, :followers => followers}]
                                    evaluations.evaluation_order_id = :evaluation_order
                                    and not(evaluations.user_id = :user and evaluations.object_user_id = :user)
                                    and (evaluations.user_id = :user or
                                         (evaluations.object_user_id = :user and not(evaluations.user_id in(:followers))))
                                  EOS
                end
                if original_parent
                  original_parent.reload
                  children = original_parent.children
                  count = 0
                  children.each do |child|
                    if child != current
                      if child.group? and child.children.count > 0
                        count += child.children.count
                      else
                        count += 1
                      end
                    else
                      count += child.all_children_count(:conditions => "evaluation_trees.user_id is not null")
                    end
                  end
                  if count < 2
                    evaluations.concat(Evaluation.only_matches_evaluation_orders(evaluation_order).find_all_by_object_user_id(original_parent.user))
                  else
                    evaluations.concat(Evaluation.find(:all, :conditions => ["evaluation_order_id = ? and evaluations.user_id = ? and evaluations.object_user_id = ?", evaluation_order, current.user, original_parent.user]))
                  end
                end
                # evaluations ||=[]
                # if confirm
                  evaluations.each do |e|
                    def e.modification
                      :destroyed
                    end
                  end
                #   @evaluations.concat(evaluations)
                # else
                  if evaluations
                    evaluations.each { |e| e.destroy }
                    @evaluations.concat(evaluations)
                  end
                # end
              end
            end
          },
          :round_robin => lambda { |current, parent, brothers, real_parent|
            evaluation_order = evaluation_orders.first
            # unless confirm
              if current.new_record?
                current.save!
              end
              if parent
                current.move_to_child_of parent
              end
            # end
            round_robin_users = [current.user].concat(brothers.collect{ |e| e.user }.compact)
            if real_parent
              round_robin_users << real_parent.user
            end
            _map = round_robin_users.inject({ }) do |_map, u|
              _map[u] ||= { }
              round_robin_users.each do |v|
                _map[u][v] = false
              end
              _map
            end
            _map = Evaluation.find(:all, :conditions => ["evaluation_order_id = :evaluation_order_id and (evaluations.user_id in(:round_robin_users) or evaluations.object_user_id in(:round_robin_users))", {:evaluation_order_id => evaluation_order, :round_robin_users => round_robin_users}]).inject(_map) do |_map, e|
              if _map[e.user]
                _map[e.user][e.object_user] = true
              end
              _map
            end
            if real_parent and !_map[current.user][real_parent.user]
              e = Evaluation.new(:evaluation_order => evaluation_order,
                                 :user => current.user,
                                 :object_user => real_parent.user)
              # if confirm
              #   add_fake_methods e, current.user, real_parent.user
              #   @evaluations << e
              # else
                def e.modification; :created; end
                e.save!
                @evaluations << e
              # end
            end
            if brothers.length > 2
              brothers.each do |u|
                brothers.each do |brother|
                  if !_map[u.user][brother.user]
                    e = Evaluation.new(:evaluation_order => evaluation_order,
                                       :user => u.user, #current.user,
                                       :object_user => brother.user) # brother.user)
                    # if confirm
                    #   add_fake_methods e, current.user, brother.user
                    #   @evaluations << e
                    # else
                    def e.modification; :created; end
                    e.save!
                    @evaluations << e
                    # end
                  end
                end
              end
              # brothers.delete current
              # brothers.each do |brother|
              #   if !_map[current.user][brother.user]
              #     e = Evaluation.new(:evaluation_order => evaluation_order,
              #                        :user => brother.user,
              #                        :object_user => current.user)
              #     # if confirm
              #     #   add_fake_methods e, brother.user, current.user
              #     #   @evaluations << e
              #     # else
              #     def e.modification; :created; end
              #     e.save!
              #     @evaluations << e
              #     # end
              #   end
              # end
              # brothers.each do |brother|
              #   if !_map[brother.user][brother.user]
              #     e = Evaluation.new(:evaluation_order => evaluation_order,
              #                        :user => brother.user,
              #                        :object_user => brother.user)
              #     # if confirm
              #     #   add_fake_methods e, brother.user, brother.user
              #     #   @evaluations << e
              #     # else
              #     def e.modification; :created; end
              #     e.save!
              #     @evaluations << e
              #     # end
              #   end
              # end
            end
          },
          :make_node_active => lambda { |current|
            # unless confirm
              current.update_attribute :selected, true
            # end
          },
          :make_children_no_round_robin => lambda { |brothers, real_parent|
            brothers = brothers.collect { |b| b.user }
            evaluation_order = evaluation_orders.first
            evaluations = Evaluation.find(:all,
                            :conditions => [<<-EOS, { :evaluation_order => evaluation_order, :brothers => brothers}])
                              evaluations.evaluation_order_id = :evaluation_order
                              and evaluations.user_id in(:brothers)
                              and evaluations.object_user_id in(:brothers)
                            EOS
            # if confirm
              evaluations.each do |e|
                def e.modification
                  :destroyed
                end
              end
            #   @evaluations.concat(evaluations)
            # else
              evaluations.each { |e| e.destroy }
              @evaluations.concat(evaluations)
            # end
          },
        }
        JSON.parse(params[:evaluation_trees] || "[]").each do |evaluation_tree|
          @klass.tranverse evaluation_tree, callbacks
        end
        EvaluationTree.find(:all, :conditions => [<<-EOS, JSON.parse(params[:deleted_evaluation_trees] || "[]")]).each do |evaluation_tree|
          evaluation_trees.id in(?)
        EOS
          @klass.remove evaluation_tree, callbacks
        end
        # unless confirm
          @klass.remove_empty_groups
        # end
        if confirm
          raise FooError
        end
        true
      end
    rescue FooError => e
      true
    end
  end

  # def add_fake_methods(e, user, object_user)
  #   e.instance_eval <<-EOV
  #     def modification; :created; end
  #     def user
  #       user = Object.new
  #       def user.name; "#{user.name}"; end
  #       def user.login; "#{user.login}"; end
  #       user
  #     end
  #     def object_user
  #       object_user = Object.new
  #       def object_user.name; "#{object_user.name}"; end
  #       def object_user.login; "#{object_user.login}"; end
  #       object_user
  #     end
  #     def scores; []; end
  #   EOV
  # end

  def build_evaluation_tree_from_csv
    if (yaml = self.class.build_yaml_buffer(params[:file], @klass)).empty?
      params[:evaluation_trees] = ""
      params[:deleted_evaluation_trees] = []
    else
      sexp = self.class.build_evaluation_tree_sexp_from_yaml(yaml)
      params[:evaluation_trees] = sexp.to_json
      params[:deleted_evaluation_trees] = @klass.find(:all, :conditions => ["not evaluation_trees.id in(?)", sexp.flatten.compact]).collect { |e| e.id }.to_json
    end
  end

  def self.build_evaluation_tree_sexp_from_yaml(yaml)
    build_evaluation_tree_sexp YAML.load_stream(StringIO.new(yaml)).documents.first
  end

  def self.build_evaluation_tree_sexp(hash)
    cons = []
    hash.each do |k, v|
      if /group\d+/ =~ k.to_s
        k = nil
      end
      if v
        cons << [k, build_evaluation_tree_sexp(v)]
      else
        cons << [k, []]
      end
    end
    cons
  end

  def self.name_id_map(file)
    head_skipped = false
    group_count = 0
    map = { }
    CSV.foreach(file) do |row|
      unless head_skipped
        head_skipped = true
        next
      end
      row[8 .. (row.length - 1)].each do |userlogin|
        userlogin = userlogin.to_s
        unless userlogin.empty?
          if /^group/ =~ userlogin
            map["group#{group_count += 1}"] = row[0]
          else
            map[userlogin] = row[0]
          end
          break
        end
      end
    end
    map
  end

  def self.build_yaml_buffer(file, klass)
    head_skipped = false
    group_count = 0
    buf = ""

    name_id_map = self.name_id_map(file)

    CSV.foreach(file) do |row|
      unless head_skipped
        if !row.collect { |c| c.to_s.toutf8 }.include?(I18n.t('note'))
          raise I18n.t('no_notes')
        end
        head_skipped = true
        next
      end
      if row[1].to_s.downcase == "false"
        next
      end
      evaluation_tree_id = row.first
      id_or_name = nil
      nestlevel = 0
      row[9 .. (row.length - 1)].each do |userlogin|
        userlogin = userlogin.to_s
        unless userlogin.empty?
          if /^group/ =~ userlogin
            groupname = "group#{group_count += 1}"
            if name_id_map[groupname]
              id_or_name = name_id_map[groupname]
            else
              id_or_name = groupname
            end
          else
            if name_id_map[userlogin]
              id_or_name = name_id_map[userlogin]
            else
              node = klass.find(:first, :include => :user, :conditions => ["users.login = ?", userlogin])
              if node
                id_or_name = node.id
              else
                raise "Cound not find EvaluationTree matchs users.login = #{userlogin}"
              end
            end
          end
          break
        end
        nestlevel += 1
      end
      buf += ("  " * nestlevel) + id_or_name.to_s + ":\n"
    end
    buf
  end
end
