# -*- coding: utf-8 -*-
namespace :ess do
  namespace :db do
    desc "delete all scores"
    task :delete_scores => :environment do
      ActiveRecord::Base.transaction do
        Score.delete_all
      end
    end

    desc "reconstruct evaluations"
    task :build_evaluations => :environment do
      ActiveRecord::Base.transaction do
        buf = EvaluationTree::TopDown.to_csv(:login, true).toutf8
        topdown_temp = open("/tmp/build_evaluations_topdown", "w") do |io|
          io << buf
        end
        buf = EvaluationTree::Multifaceted.to_csv(:login, true).toutf8
        multifaceted_temp = open("/tmp/build_evaluations_multifaceted", "w") do |io|
          io << buf
        end

        puts "Deleting all evaluations"
        Evaluation.delete_all

        puts "Flat evaluation tree"
        EvaluationTree.find_by_sql "update evaluation_trees set parent_id=NULL, selected=false"
        EvaluationTree.renumber_all

        controller = EvaluationTreesController.new

        puts "Constructing the topdown evaluations"
        klass = EvaluationTree::TopDown
        controller.instance_eval "@klass = EvaluationTree::TopDown"
        controller.params = { }
        controller.params[:file] = topdown_temp.path
        controller.send :build_evaluation_tree_from_csv
        controller.send :confirm_or_update

        puts "Constructing the multifaceted evaluations"
        controller.instance_eval "@klass = EvaluationTree::Multifaceted"
        controller.params[:file] = multifaceted_temp.path
        controller.send :build_evaluation_tree_from_csv
        controller.send :confirm_or_update

        puts "Done successfully"
      end
    end

    desc "load real database"
    task :real_load => :environment do
      Rake::Task["ess:db:kill_processes"].invoke
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      hostname = "ess.example.com"
      execute_shell <<EOS
ssh -o BatchMode=yes -o ConnectTimeout=3 #{hostname} "pg_dump -U postgres ess_production" | tee ess_production-`date +%y%m%d`.sql | psql -U postgres ess_development
EOS
      Rake::Task["db:migrate"].invoke
    end

    def execute_shell(s)
      %x! #{ s } !
      raise RuntimeError.new(<<EOS) unless $?.to_i.zero?
Could not execute following shell command.
#{ s}
EOS
    end

    desc "build_evaluation_tree"
    task :build_evaluation_tree => :environment do
      ActiveRecord::Base.transaction do
        EvaluationTree.delete_all

        _map = { }

        user_ids = Evaluation.all.collect { |e| [e.user_id, e.object_user_id] }.flatten.uniq

        user_ids.each do |user_id|
          _map[user_id] = {
            :topdown => EvaluationTree::TopDown.create!(:user_id => user_id),
            :multifaceted => EvaluationTree::Multifaceted.create!(:user_id => user_id)
          }
        end

        activated_trees=[]

        # 上長評価
        Evaluation.only_matches_evaluation_orders(EvaluationOrder::TopDown.first).each do |e|
          parent = _map[e.user_id][:topdown]
          child = _map[e.object_user_id][:topdown]
          EvaluationTree.find_by_sql([<<-EOS, parent, child, EvaluationTree::TopDown.to_s])
            update evaluation_trees set parent_id =? where id=? and type=?
          EOS
          activated_trees << parent.id
          activated_trees << child.id
        end

        # 多面評価 - 単方向評価(= 上長への評価)のみ
        Evaluation.find_by_sql([<<-EOS, { :order => EvaluationOrder::Multifaceted.first}]).each do |e|
          select
            evaluations.id
          , evaluations.user_id
          , evaluations.object_user_id
          from evaluations
          where
            evaluations.evaluation_order_id = :order
            and evaluations.user_id <> evaluations.object_user_id
            and evaluations.id not in(
              select
                evaluations.id
              from evaluations
              left outer join evaluations evaluations2 on
                evaluations2.user_id = evaluations.object_user_id
                and evaluations.user_id = evaluations2.object_user_id
              where
                evaluations.user_id <> evaluations.object_user_id
                and evaluations.evaluation_order_id = :order
                and evaluations2.evaluation_order_id = :order
              group by
                evaluations.id)
        EOS
          parent = _map[e.object_user_id][:multifaceted]
          child = _map[e.user_id][:multifaceted]
          EvaluationTree.find_by_sql([<<-EOS, parent, child, EvaluationTree::Multifaceted.to_s])
            update evaluation_trees set parent_id=? where id=? and type=?
          EOS
          activated_trees << parent.id
          activated_trees << child.id
        end

        # 多面評価 - 双方向評価(= 相互評価)のみ
        h = { }
        Evaluation.find_by_sql([<<-EOS, { :order => EvaluationTree::Multifaceted}]).each do |e|
          select
            evaluations.id
          , evaluations.user_id
          , evaluations.object_user_id
          from evaluations
          left outer join evaluations evaluations2 on
            evaluations2.user_id = evaluations.object_user_id
            and evaluations.user_id = evaluations2.object_user_id
          where
            evaluations.user_id <> evaluations.object_user_id
            and evaluations.evaluation_order_id = 3
            and evaluations2.evaluation_order_id = 3
        EOS
          ary = h[e.user_id]
          if ary.nil?
            ary = []
          end
          unless ary.include?(e.user_id)
            ary << e.user_id
          end
          unless ary.include?(e.object_user_id)
            ary << e.object_user_id
          end
          h[e.user_id] = ary
          h[e.object_user_id] = ary
        end

        h.values.uniq.collect do |group_members|
          group_members = group_members.collect do |user_id|
            _map[user_id][:multifaceted]
          end
          group_parents = group_members.collect { |e|
            e.parent
          }.uniq
          if group_parents.length > 1
            group_parent = group_parents.select {|e| !e.nil?}.first
          else
            group_parent = group_parents.first
          end

          group = EvaluationTree::Multifaceted.create!
          activated_trees << group

          if group_parent
            activated_trees << group_parent
            group.move_to_child_of group_parent
          end
          group_members.each do |e|
            e.move_to_child_of group
            activated_trees << e
          end
        end
        EvaluationTree.find_by_sql([<<-EOS, true, activated_trees])
          update evaluation_trees set selected = ? where id in(?)
        EOS
        EvaluationTree.renumber_all
      end
    end

    desc "setup"
    task :setup => :environment do
      # recreate all databases
      # ActiveRecord::Base.clear_all_connections!
      Rake::Task["ess:db:kill_processes"].invoke
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke

      # switch database context to development
      environment = ENV["RAILS_ENV"] || "development"
      db_conf = Rails.application.config.database_configuration["development"]

      if File.exists?(ess_sql_file = File.expand_path('ess.sql', ENV['PWD']))
        puts "ess.sql exists, trying to load it."
        system "cat #{ess_sql_file}| psql -U #{db_conf["username"]} #{db_conf["database"]} > /dev/null 2>&1"
        Rake::Task["ess:db:shuffle"].invoke
      else
        puts "ess.sql does not exist, skip to load it."
      end
      Rake::Task["db:migrate"].invoke
      # Rake::Task["db:seed"].invoke
      # Rake::Task["ess:db:build_evaluation_tree"].invoke

      # setup database for test
      # db_conf = Rails.application.config.database_configuration["test"]
      # ActiveRecord::Base.clear_all_connections!
      # ActiveRecord::Base.establish_connection db_conf
      # Rake::Task["db:migrate"].invoke
      # Rake::Task["db:seed"].invoke
      # Rake::Task["ess:db:build_evaluation_tree"].invoke
    end

    desc "shuffles employee scores"
    task :shuffle => :environment do
      # http://stackoverflow.com/questions/876396/do-rails-rake-tasks-provide-access-to-activerecord-models
      points = Point.all
      query = Score.find(:all).collect { |score|
        Score.send :sanitize_sql,
        ["update scores set point_id = ? where id = ?;",
         points.shuffle.first.id, score.id]
      }.join

      # Executing raw SQL in Rails.
      # http://www.rabbitcreative.com/2007/06/08/executing-raw-sql-in-rails/
      ActiveRecord::Base.connection.execute query
    end

    desc "kill all processes that are connecting to databases"
    task "kill_processes" do
      system "killall psql > /dev/null 2>&1"
      pids = %x{echo `ps x -o pid,command|expand|tr -s ' ' ' '|sed 's/^\s//g'|grep -v grep|grep server|cut -d ' ' -f1`}
      if /\d+/ =~ pids
        %x{echo "#{pids}"|xargs kill -SIGINT}
      end
      sleep 3
    end
  end
end
