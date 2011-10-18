# -*- coding: utf-8 -*-

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include ApplicationHelper

  belongs_to :qualification
  belongs_to :item_group

  has_many :belongs, :dependent => :destroy
  has_many :divisions, :through => :belongs do
    def primary
      find :first, :conditions => 'primary_flag is true'
    end
  end
  has_many :job_titles, :through => :belongs
  has_many :roles_users, :dependent => :destroy
  has_many :roles, :through => :roles_users do
    def admin?
      find_by_type(Role::Admin.to_s) ? true : false
    end
    def decider?
      find_by_type(Role::Decider.to_s) ? true : false
    end
  end

  # 能動評価 (他人への評価)
  has_many :evaluations
  accepts_nested_attributes_for :evaluations, :allow_destroy => true

  has_many :evaluation_orders, :through => :evaluations
  has_many :object_users, :through => :evaluations

  # 受動評価 (他人から受けた評価)
  has_many :passive_evaluations,
           :foreign_key => :object_user_id,
           :class_name => Evaluation.to_s,
           :include => [:user, :scores]

  has_many :evaluators, :through => :passive_evaluations, :source => :user do
    def evaluation_order_only(evaluation_order)
      self.joins(<<-EOS).where("evaluation_orders.id = ?", evaluation_order)
        join evaluation_orders on evaluation_orders.id = evaluations.evaluation_order_id
      EOS
    end
  end

  has_many :evaluation_trees, :dependent => :destroy
  accepts_nested_attributes_for :evaluation_trees, :allow_destroy => true

  attr_accessible :evaluations_attributes, :qualification_id, :qualification, :item_group_id, :item_group, :email, :name, :kana, :code, :note, :excluded

  has_one :adjustment

  has_many :answers
  has_many :questions, :through => :answers

  def has_topdown_evaluations?
    !self.evaluations.scoped_by_evaluation_order_type(EvaluationOrder::TopDown).empty?
  end

  def interviews
    interviews = Interview.where(:evaluation_id => self.passive_evaluations)
    def interviews.done?
      self.inject(false) do |done, interview|
        done | interview.done?
      end
    end
    interviews
  end

  def self.users_have_multifaceted_evaluation(users=[])
    if users.empty?
      users = User.find_by_sql(<<-EOS)
        select users.id
        from users
        left join evaluations on
          evaluations.user_id = users.id
        left join evaluation_orders on
          evaluation_orders.id = evaluations.evaluation_order_id
        left join evaluation_groups on
          evaluation_groups.id = evaluation_orders.evaluation_group_id
          and evaluation_groups.type = 'EvaluationGroup::Multifaceted'
        group by users.id
        having count(evaluations.id) > 1
      EOS
    else
      users = User.find_by_sql([<<-EOS, users])
        select users.id
        from users
        left join evaluations on
          evaluations.user_id = users.id
        left join evaluation_orders on
          evaluation_orders.id = evaluations.evaluation_order_id
        left join evaluation_groups on
          evaluation_groups.id = evaluation_orders.evaluation_group_id
          and evaluation_groups.type = 'EvaluationGroup::Multifaceted'
        where users.id in(?)
        group by users.id
        having count(evaluations.id) > 1
      EOS
    end
    users.inject({ }) do |hash, user|
      hash.merge({ user.id.to_i => true })
    end
  end

  def self.multifaceted_evaluation_score_average
    self.find_by_sql(self.sql_multifaceted_evaluation_score_average).first.average.to_f
  end

  def self.sql_multifaceted_evaluation_score_average(with_condition_for_users=false)
    <<-EOS
      select
        avg(totals.raw_aggregated_multifaceted_average_score) as average
      from
        (#{self.sql_aggregate_each_user(with_condition_for_users)}) as totals
    EOS
  end

  def self.aggregate_each_user(*users)
    topdown_evaluation_group = EvaluationGroup::TopDown.first
    multifaceted_evaluation_group = EvaluationGroup::Multifaceted.first
    have_users_multifaceted_evaluation = self.users_have_multifaceted_evaluation(users)
    multifaceted_evaluation_score_average = self.multifaceted_evaluation_score_average
    if users.empty?
      users = User.find_by_sql(self.sql_aggregate_each_user(false))
    else
      users = User.find_by_sql([self.sql_aggregate_each_user(true), users])
    end
    users.collect do |user|
      user.instance_eval do
        @_topdown_evaluation_group = topdown_evaluation_group
        @_multifaceted_evaluation_group = multifaceted_evaluation_group
        @_multifaceted_evaluation_score_average = multifaceted_evaluation_score_average
      end
      if have_users_multifaceted_evaluation[user.id]
        def user.total
          if self.aggregated_raw_perfect_score.to_f.zero?
            (self.raw_aggregated_multifaceted_average_score.to_f / self.aggregated_raw_multifaceted_max_score.to_f * 100).round(2)
          else
            ((self.aggregated_raw_score.to_f / self.aggregated_raw_perfect_score.to_f * @_topdown_evaluation_group.weight * 100).round(2) + ((self.raw_aggregated_multifaceted_average_score.to_f.zero? ? @_multifaceted_evaluation_score_average : self.raw_aggregated_multifaceted_average_score.to_f) / self.aggregated_raw_multifaceted_max_score.to_f * @_multifaceted_evaluation_group.weight * 100).round(2)).round(2)
          end
        end
      else
        def user.total
          if self.aggregated_raw_perfect_score.to_f.zero?
            0
          else
            ((self.aggregated_raw_score.to_f / self.aggregated_raw_perfect_score.to_f * @_topdown_evaluation_group.weight * 100).round(2) + (@_multifaceted_evaluation_score_average / self.aggregated_raw_multifaceted_max_score.to_f * @_multifaceted_evaluation_group.weight * 100).round(2)).round(2)
          end
        end
      end
      user
    end
  end

  def self.sql_aggregate_each_user(with_condition_for_users=false)
    <<-EOS
      select
        aggregates.user_id as id
      , sum(aggregates.raw_score) as aggregated_raw_score
      , sum(aggregates.raw_first_topdown_evaluation_score) as aggregated_raw_first_topdown_evaluation_score
      , sum(aggregates.raw_second_topdown_evaluation_score) as aggregated_raw_second_topdown_evaluation_score
      , sum(aggregates.raw_perfect_score) as aggregated_raw_perfect_score
      , sum(aggregates.raw_multifaceted_average_score) as raw_aggregated_multifaceted_average_score
      , sum(aggregates.raw_multifaceted_max_score) as aggregated_raw_multifaceted_max_score
      from (#{self.sql_aggregate_each_evaluation_item(with_condition_for_users)}) as aggregates
      group by aggregates.user_id
    EOS
  end

  def self.sql_aggregate_each_evaluation_item(with_condition_for_users=false)
    max_point = Point.maximum :point
    <<-EOS
      select
        users.id as user_id
      , evaluation_groups.id as evaluation_group_id
      , item_belongs.id as item_belong_id
      , evaluation_items.id as evaluation_item_id
      , case
        when evaluation_groups.id = #{EvaluationGroup::TopDown.first.id} then
          sum(points.point * evaluation_orders.weight * item_belongs.weight * items_qualifications.weight)
        end as raw_score
      , case
        when evaluation_groups.id = #{EvaluationGroup::TopDown.first.id} then
          sum(points.point * item_belongs.weight * items_qualifications.weight * (case when evaluation_orders.id = #{EvaluationOrder::TopDown.first.id} then 1.0 else 0.0 end))
        end as raw_first_topdown_evaluation_score
      , case
        when evaluation_groups.id = #{EvaluationGroup::TopDown.first.id} then
          sum(points.point * item_belongs.weight * items_qualifications.weight * (case when evaluation_orders.id = #{EvaluationOrder::TopDown.last.id} then 1.0 else 0.0 end))
        end as raw_second_topdown_evaluation_score
      , case
        when evaluation_groups.id = #{EvaluationGroup::TopDown.first.id} then
          sum(#{max_point} * evaluation_orders.weight * item_belongs.weight)
        end as raw_perfect_score
      , case
        when evaluation_groups.id = #{EvaluationGroup::Multifaceted.first.id} then
          round(avg(points.point)::NUMERIC, 2)
        end as raw_multifaceted_average_score
      , case
        when evaluation_groups.id = #{EvaluationGroup::Multifaceted.first.id} then
          #{max_point}
        end as raw_multifaceted_max_score
      from users
      left join item_groups on
        item_groups.id = users.item_group_id
      left join item_belongs on
        item_belongs.item_group_id = item_groups.id
      left join items on
        items.id = item_belongs.item_id
      left join evaluation_items on
        evaluation_items.id = items.evaluation_item_id
      left join evaluation_categories on
        evaluation_categories.id = items.evaluation_category_id
      left join evaluation_groups on
        evaluation_groups.id = evaluation_categories.evaluation_group_id
      left join qualifications on
        qualifications.id = users.qualification_id
      left join items_qualifications on
        items_qualifications.qualification_id = qualifications.id
        and items_qualifications.item_id = items.id
      left join evaluations on
        evaluations.object_user_id = users.id
      left join evaluation_orders on
        evaluation_orders.id = evaluations.evaluation_order_id
        and evaluation_orders.evaluation_group_id = evaluation_groups.id
      left join scores on
        scores.evaluation_id = evaluations.id
        and scores.item_belong_id = item_belongs.id
      left join points on
        points.id = scores.point_id
      #{with_condition_for_users ? "where users.id in(?)" : ""}
      group by
        users.id, evaluation_groups.id, item_belongs.id, item_belongs.seq, evaluation_items.id
      order by
        users.id, evaluation_groups.id, item_belongs.seq
    EOS
  end

  def has_self_evaluation?
    !Evaluation.count(:conditions => ["user_id = :me and object_user_id = :me and evaluation_order_id in(:orders)", {:me => self, :orders => EvaluationOrder::Multifaceted.all}]).zero?
  end

  def self.make_users_interviews!(users)
    users_interviews = self.find_by_sql([<<-EOS, EvaluationGroup::TopDown.first, users]).inject({ }) do |h, interview|
      select
        users.id as user_id
      , bool_or(case when interviews.done_at is not null then true else false end) as done
      from users
      inner join evaluations on evaluations.object_user_id = users.id
      left outer join evaluation_orders on evaluation_orders.id = evaluations.evaluation_order_id
      left outer join evaluation_groups on evaluation_groups.id = evaluation_orders.evaluation_group_id
      left outer join interviews on interviews.evaluation_id = evaluations.id
      where evaluation_groups.id = ? and users.id in(?)
      group by users.id
    EOS
      h.merge({ interview.user_id.to_i => (interview.done == "t") })
    end
    users.each do |user|
      user.instance_eval do
        @_interview_done = users_interviews[user.id]
      end
      def interview_done?
        @_interview_done
      end
    end
  end

  def self.make_users_scores!(users)
    topdown_evaluation_group = EvaluationGroup::TopDown.first
    multifaceted_evaluation_group = EvaluationGroup::Multifaceted.first

    users_scores = self.find_by_sql([self.sql_aggregate_each_evaluation_item(true), users]).inject({ }) do |h, score|
      h[score.user_id.to_i] ||= []
      h[score.user_id.to_i] << score
      h
    end

    users_aggregated_scores = self.find_by_sql([self.sql_aggregate_each_user(true), users]).inject({ }) do |h, score|
      h.merge({ score.id => score })
    end

    users_multifaceted_evaluations_num = Evaluation.
      joins(:object_user, {:evaluation_order => :evaluation_group}).
      where("evaluation_groups.type = ? and users.id in(?)", EvaluationGroup::Multifaceted.to_s, users).
      group("users.id").
      count(:id)

    multifaceted_evaluation_score_average = self.multifaceted_evaluation_score_average

    users.each do |user|
      multifaceted_evaluations_num = users_multifaceted_evaluations_num[user.id].to_i
      scores = users_scores[user.id]
      scores.each do |score|
        score.instance_eval do
          def item_belong
            if @_item_belong
              @_item_belong
            else
              @_item_belong = ItemBelong.find_by_id attributes["item_belong_id"]
            end
          end
          def evaluation_item
            if @_evaluation_item
              @_evaluation_item
            else
              @_evaluation_item = EvaluationItem.find_by_id attributes["evaluation_item_id"]
            end
          end
          def evaluation_category
            if @_evaluation_category
              @_evaluation_category
            else
              @_evaluation_category = self.item_belong.item.evaluation_category # evaluation_item.evaluation_categories.first
            end
          end
          def evaluation_group
            if @_evaluation_group
              @_evaluation_group
            else
              EvaluationGroup.find_by_id attributes["evaluation_group_id"]
            end
          end
          def score
            self.attributes["raw_score"].to_f
          end
          def first_topdown_evaluation_score
            self.attributes["raw_first_topdown_evaluation_score"].to_f
          end
          def second_topdown_evaluation_score
            self.attributes["raw_second_topdown_evaluation_score"].to_f
          end
          def score
            self.attributes["raw_score"].to_f
          end
          def perfect_score
            self.attributes["raw_perfect_score"].to_f
          end
          def multifaceted_average_score
            self.attributes["raw_multifaceted_average_score"].to_f
          end
          def multifaceted_max_score
            self.attributes["raw_multifaceted_max_score"].to_f
          end
          def evaluation_group_id
            if self.attributes["evaluation_group_id"]
              self.attributes["evaluation_group_id"].to_i
            end
          end
          def evaluation_item_id
            if self.attributes["evaluation_item_id"]
              self.attributes["evaluation_item_id"].to_i
            end
          end
          def item_belong_id
            if self.attributes["item_belong_id"]
              self.attributes["item_belong_id"].to_i
            end
          end
        end
      end
      scores.instance_eval do
        @_topdown_evaluation_group = topdown_evaluation_group
        @_multifaceted_evaluation_group = multifaceted_evaluation_group
      end
      aggregated_score = users_aggregated_scores[user.id]
      scores.instance_eval do
        @_aggregated_score = aggregated_score
      end

      def scores.topdown_evaluation_total
        @_aggregated_score.aggregated_raw_score.to_f
      end
      def scores.first_topdown_evaluation_total
        @_aggregated_score.aggregated_raw_first_topdown_evaluation_score.to_f
      end
      def scores.second_topdown_evaluation_total
        @_aggregated_score.aggregated_raw_second_topdown_evaluation_score.to_f
      end
      def scores.topdown_evaluation_perfect_score
        @_aggregated_score.aggregated_raw_perfect_score.to_f
      end
      if multifaceted_evaluations_num.zero?
        scores.instance_eval do
          @_multifaceted_evaluation_total = multifaceted_evaluation_score_average
        end
        def scores.multifaceted_evaluation_total
          (@_multifaceted_evaluation_total).round(2)
        end
      else
        def scores.multifaceted_evaluation_total
          (@_aggregated_score.raw_aggregated_multifaceted_average_score.to_f).round(2)
        end
      end
      def scores.multifaceted_evaluation_perfect_score
        @_aggregated_score.aggregated_raw_multifaceted_max_score.to_f
      end
      def scores.total_first_topdown_evaluation
        if self.topdown_evaluation_perfect_score.to_f.zero?
          0
        else
          (self.first_topdown_evaluation_total.to_f / self.topdown_evaluation_perfect_score.to_f * @_topdown_evaluation_group.weight * 100).round(2)
        end
      end
      def scores.total_second_topdown_evaluation
        if self.topdown_evaluation_perfect_score.to_f.zero?
          0
        else
          (self.second_topdown_evaluation_total.to_f / self.topdown_evaluation_perfect_score.to_f * @_topdown_evaluation_group.weight * 100).round(2)
        end
      end
      def scores.total_topdown_evaluation
        if self.topdown_evaluation_perfect_score.to_f.zero?
          0
        else
          (self.topdown_evaluation_total.to_f / self.topdown_evaluation_perfect_score.to_f * @_topdown_evaluation_group.weight * 100).round(2)
        end
      end
      def scores.total_multifaceted_evaluation
        if self.multifaceted_evaluation_perfect_score.to_f.zero?
          0
        else
          (self.multifaceted_evaluation_total.to_f / self.multifaceted_evaluation_perfect_score.to_f * @_multifaceted_evaluation_group.weight * 100).round(2)
        end
      end
      def scores.total
        (self.total_topdown_evaluation + self.total_multifaceted_evaluation).round(2)
      end
      def scores.total_first_topdown_plus_multifaceted
        (self.total_first_topdown_evaluation + self.total_multifaceted_evaluation).round(2)
      end
      def scores.total_second_topdown_plus_multifaceted
        (self.total_second_topdown_evaluation + self.total_multifaceted_evaluation).round(2)
      end
      scores.instance_eval do
        @_adjustment_value = user.adjustment_value
      end
      def scores.adjusted_total
        self.total + @_adjustment_value
      end
      def scores.to_custom_hash
        if defined?(@_to_custom_hash)
          @_to_custom_hash
        else
          @_to_custom_hash = self.inject(self.inject({ }) { |h, score|
                                           h.merge({ score.evaluation_group_id => { }})
                                         }) do |h, score|
            h[score.evaluation_group_id][score.evaluation_item_id] = { :score => score.score, :average => score.multifaceted_average_score }
            h
          end
        end
      end
      scores.instance_eval do
        @_multifaceted_evaluations_num = multifaceted_evaluations_num
      end
      def scores.multifaceted_evaluations_num
        @_multifaceted_evaluations_num
      end
      def scores.each_topdown_evaluation_category
        scores_grouped_topdown_evaluation = self.select do |score|
          score.evaluation_group_id == @_topdown_evaluation_group.id
        end
        hash = scores_grouped_topdown_evaluation.inject({ }) do |hash, score|
          hash[score.evaluation_category] ||= []
          hash[score.evaluation_category] << { :item => score.evaluation_item.name, :score => score.score }
          hash
        end
        scores_grouped_topdown_evaluation.collect { |score|
          score.evaluation_category
        }.uniq.collect { |category|
          {
            :category => category.name,
            :items => hash[category]
          }
        }
      end
      def scores.each_multifaceted_evaluation_category
        hash = self.select { |score|
          score.evaluation_group_id == @_multifaceted_evaluation_group.id
        }.collect { |score|
          {
            :item => score.evaluation_item.name,
            :score => score.multifaceted_average_score,
          }
        }
      end
      user.instance_eval do
        @_scores = users_scores[user.id]
      end
      def user.scores
        @_scores
      end
    end
    def users.to_custom_hash
      {
        :evaluation_term => System.describe_evaluation_term,
        :topdown_evaluation_weight => EvaluationGroup::TopDown.first.weight,
        :multifaceted_evaluation_weight => EvaluationGroup::Multifaceted.first.weight,
        :users => self.collect { |user|
          {
            :name => user.name,
            :division => (user.divisions.any? ? user.divisions.first.name : ""),
            :qualification => (user.qualification ? user.qualification.name : ""),
            :topdown_results => user.scores.each_topdown_evaluation_category,
            :topdown_total => user.scores.topdown_evaluation_total.to_s,
            :multifaceted_results => user.scores.each_multifaceted_evaluation_category,
            :multifaceted_total => user.scores.multifaceted_evaluation_total.to_s,
            :topdown_perfect => user.scores.topdown_evaluation_perfect_score.to_s,
            :multifaceted_perfect => user.scores.multifaceted_evaluation_perfect_score.to_s,
            :score => user.scores.total.to_s,
            :adjustment_value => user.adjustment_value.to_s,
            :adjusted_score => user.adjusted_total.to_s,
            :rank => Rank.find_by_score(user.adjusted_total).name,
            :multifaceted_evaluators_number => user.scores.multifaceted_evaluations_num,
          }
        }
      }
    end
    def users.to_csv
      User.make_users_interviews!(self)

      CSV.generate do |csv|
        head = [I18n.t('employee_name'), I18n.t('employee_code'), I18n.t('affiliation'), I18n.t('qualification'), I18n.t('job_title'), I18n.t('topdown_eval'), I18n.t('multifaceted_eval'), I18n.t('fixed_score'), I18n.t('evaluation'), I18n.t('adjustment_point'), I18n.t('overall_eval_point'), I18n.t('overall_eval'), I18n.t('interviewed_check')]
        csv << head
        self.each do |user|
          col = [
                 user.name,
                 user.code,
                 (user.divisions.empty? ? "" : user.divisions.first.name),
                 user.qualification_name,
                 user.job_titles.collect {|job_title| job_title.name}.join("\n"),
                 user.scores.total_topdown_evaluation,
                 user.scores.total_multifaceted_evaluation,
                 user.scores.total,
                 Rank.find_by_score(user.scores.total).name,
                 user.adjustment_value,
                 user.adjusted_total,
                 Rank.find_by_score(user.scores.adjusted_total).name,
                 user.interview_done? ? I18n.t('done') : I18n.t('yet'),
                ]
          csv << col
        end
      end
    end
    users
  end

  def qualification_name
    if self.qualification
      self.qualification.name
    end
  end

  def adjustment_value
    adjustment ? adjustment.value.to_f : 0.0
  end

  def adjusted_total
    if self.respond_to?(:total)
      self.total + adjustment_value
    elsif self.respond_to?(:scores)
      self.scores.adjusted_total
    end
  end

  def item_belongs_scoped_by_evaluation_category(evaluation_category) # FIXME:protected?
    ItemBelong.find(:all,
                    :include => [{ :item_group => :users}, { :item => [:evaluation_item, :evaluation_category]}],
                    :order => 'evaluation_items.id',
                    :conditions => ['evaluation_categories.id = ? and users.id = ?', evaluation_category, self])
  end

  def evaluation_item_map
    EvaluationCategory.evaluation_item_map_by_user self
  end

  def evaluation_item_score_map
    find_evaluation_item_score_map.inject({ }) do |map, score|
      map[score.evaluation_item_id.to_i] ||= { }
      map[score.evaluation_item_id.to_i][score.evaluation_order_id.to_i] = score.average.to_f
      map
    end
  end

  def find_evaluation_item_score_map
    self.class.find_by_sql([<<-SQL, self])
      select
        evaluation_orders.id as evaluation_order_id
      , evaluation_items.id as evaluation_item_id
      , avg(points.point) as average
      from users
      inner join evaluations on
        evaluations.object_user_id = users.id
      inner join evaluation_orders on
        evaluation_orders.id = evaluations.evaluation_order_id
      left outer join scores on
        scores.evaluation_id = evaluations.id
      left outer join item_belongs on
        item_belongs.id = scores.item_belong_id
      left outer join items on
        items.id = item_belongs.item_id
      left outer join evaluation_items on
        evaluation_items.id = items.evaluation_item_id
      left outer join points on
        points.id = scores.point_id
      where
        users.id = ?
      group by
        evaluation_items.id, evaluation_orders.id
    SQL
  end

  scope :scoped_by_phrase, lambda { |phrase|
    count = 0
    phrases = phrase.to_s.gsub(/　/, ' ').split(/\s+/).inject({ }) { |h, p|
      h.merge({ "phrase#{count += 1}".to_sym => "%#{p}%" })
    }
    {
      :include => :divisions,
      :conditions => [
                      phrases.keys.collect { |p|
                        "(%s)" %
                          [
                           "users.login",
                           "users.email",
                           "users.name",
                           "users.kana",
                           "users.code",
                           "divisions.name",
                          ].collect { |f|
                            "(#{f} like :#{p})"
                          }.join(' or ')
                      }.join(' and '),
                      phrases
                     ]
    }
  }

  scope :scoped_by_division_full_set, lambda { |division|
    division = Division.find_by_id division
    if division
      {
        :include => :divisions,
        :conditions => ['divisions.id in (?)', division.full_set],
        :order => "users.kana"
      }
    end
  }

  scope :scope_by_evaluation_order_type, lambda { |type|
    {
      :joins => "inner join evaluation_orders on evaluation_orders.id = evaluations.evaluation_order_id",
      :conditions => ["evaluation_orders.type = ?", type]
    }
  }

  scope :only_unevaluated, lambda { |evaluator, evaluation_category|
    {
      :joins => sanitize_sql([<<-EOS, evaluator, evaluation_category]),
        inner join (
            select
              users.id
            from evaluations
            left outer join users on users.id = evaluations.object_user_id
            left outer join item_groups on item_groups.id = users.item_group_id
            left outer join item_belongs on item_belongs.item_group_id = item_groups.id
            left outer join items on items.id = item_belongs.item_id
            left outer join evaluation_categories on evaluation_categories.id = items.evaluation_category_id
            left outer join scores on
              scores.item_belong_id = item_belongs.id
              and scores.evaluation_id = evaluations.id
            left outer join points on points.id = scores.point_id
            where
              evaluations.user_id = ?
              and evaluation_categories.id = ?
            group by
              users.id
            having
              bool_and(points.id is not null) is false
          ) as unevaluated_object_users on
          unevaluated_object_users.id = users.id
      EOS
    }
  }

  scope :order_by_user_kana, lambda {
    {
      :order => "users.kana"
    }
  }

  scope :under_evaluation_tree, lambda { |evaluation_tree|
    {
      :include => :evaluation_trees,
      :conditions => ["evaluation_trees.id <> ? and (evaluation_trees.lft between ? and ?)", evaluation_tree, evaluation_tree.lft, evaluation_tree.rgt],
      :order => "users.kana",
    }
  }

  scope :under_division_tree, lambda { |*divisions|
    {
      :order => "users.kana",
      # Not division.full_set
      :joins => sanitize_sql([<<-EOS, divisions.collect { |d| d.all_children }.flatten.collect { |d| d.id }.uniq ])
join (select
      users.id
      from users
      join belongs on belongs.user_id = users.id
      join divisions on divisions.id = belongs.division_id
      where
      divisions.id in(?)
      group by users.id) users_under_division on users_under_division.id = users.id
EOS
    }
  }

  scope :under_division_tree_full_set, lambda { |*divisions|
    {
      :order => "users.kana",
      :joins => sanitize_sql([<<-EOS, divisions.collect { |d| d.full_set }.flatten.collect { |d| d.id }.uniq])
join (select
      users.id
      from users
      join belongs on belongs.user_id = users.id
      join divisions on divisions.id = belongs.division_id
      where
      divisions.id in(?)
      group by users.id) users_under_division on users_under_division.id = users.id
EOS
    }
  }

  scope :uninterviewed, lambda {
    {
      :joins => sanitize_sql([<<-EOS, EvaluationGroup::TopDown.first]),
        join (select
                users.id as user_id
              , bool_or(case when interviews.done_at is not null then true else false end) as done
              from users
              join evaluations on evaluations.object_user_id = users.id
              left join evaluation_orders on evaluation_orders.id = evaluations.evaluation_order_id
              left join evaluation_groups on evaluation_groups.id = evaluation_orders.evaluation_group_id
              left join interviews on interviews.evaluation_id = evaluations.id
              where evaluation_groups.id = ?
              group by users.id) aggregated_interviews on aggregated_interviews.user_id = users.id
      EOS
      :conditions => "aggregated_interviews.done is false"
    }
  }

  scope :all_evaluatees, lambda {
    {
      :joins => <<-EOS
        join (select users.id as id
              from users
              join evaluations on evaluations.object_user_id = users.id
              group by users.id) evaluatees on evaluatees.id = users.id
      EOS
    }
  }

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message



  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    begin
      if AppConfig.authentication_method == "none"
        u
      elsif AppConfig.authentication_method == "local"
        u && u.authenticated?(password) ? u : nil
      elsif AppConfig.authentication_method == "ldap"
        u && ActiveLdapUser.authenticate2(u.login, password) ? u : nil
      else
        raise NoMethodError
      end
    rescue NoMethodError => e
      raise NoMethodError.new("AppConfig.authentication_method is not configured. Make sure that config/app_config.yml or config/environments/<environment>.yml exists well")
    end
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def build_evaluation_score_sheet(object_user, category, with_others_evaluations=true)
    category = EvaluationCategory.find category
    evaluation_orders = category.class.evaluation_type.all
    cons = []

    object_user = self.class.find object_user

    item_belongs = object_user.item_group.item_belongs.scope_by_evaluation_category_and_order_by_evaluation_item(category)

    item_belongs.each do |item_belong|
      cons2 = []
      cons3 = []
      cons2 << cons3

      cons3 << {:user_id => self.id, :user_name => self.name, :object_user_id => object_user.id}

      cons33 = []
      cons3 << cons33

      foo(evaluation_orders, object_user).each do |e|
        score = item_belong.scores.find_by_evaluation_id e
        unless score
          score = item_belong.scores.build :evaluation => e
        end
        cons33 << {:evaluation_order_name => e.evaluation_order.name, :point_id => (score.point ? score.point.id : nil), :id => score.id, :item_belong_id => score.item_belong_id, :evaluation_id => score.evaluation_id}
      end

      if with_others_evaluations
        object_user.passive_evaluations.only_matches_evaluation_orders(*evaluation_orders).exclude_by_user(self).each do |e2|

          cons4 = []
          cons2 << cons4

          cons44 = []
          cons4 << {:user_id => e2.user.id, :user_name => e2.user.name, :object_user_id => object_user.id}
          cons4 << cons44

          score = item_belong.scores.find_by_evaluation_id e2
          unless score
            score = item_belong.scores.build :evaluation => e2
          end
          cons44 << {:evaluation_order_name => e2.evaluation_order.name, :point_id => (score.point ? score.point.id : nil), :id => score.id, :item_belong_id => score.item_belong_id, :evaluation_id => score.evaluation_id}
        end
      end

      cons << [item_belong.item.evaluation_item.name, item_belong.note, cons2]
    end

    cons
  end

  def foo(evaluation_orders, object_user)
    evaluations.find(:all,
                     :include => {:scores => {:item_belong => {:item => :evaluation_item}}},
                     :conditions => [<<-EOS, evaluation_orders, object_user],
                       evaluations.evaluation_order_id in (?) and evaluations.object_user_id = ?
                     EOS
                     :order => 'evaluation_items.id')
  end

  def division_name_paths
    divisions.collect { |d|
      d.full_path.collect { |i| i.name }.reverse.join(' ')
    }
  end

  def incomplete_users
    evaluation_tree = EvaluationTree::TopDown.find_by_user_id(self)
    evaluation_trees = [evaluation_tree].concat(evaluation_tree.all_children)
    user_ids = evaluation_trees.collect { |e| e.user }
    users = self.class.find_by_sql([<<-EOS, {:user_ids => user_ids, :multifaceted => EvaluationOrder::Multifaceted.all, :multifaceted_category => EvaluationCategory::Multifaceted.all}])
      select
        users.*
      , incomplete_evaluations.is_complete as done
      from users
      left join (select
                   users.id as id
                 , bool_and(case
                            when points.id is not null then true
                            else false
                            end) as is_complete
                 from users
                 inner join evaluations on
                   evaluations.user_id = users.id
                 inner join users object_users on
                   object_users.id = evaluations.object_user_id
                 inner join item_groups on
                   item_groups.id = object_users.item_group_id
                 inner join item_belongs on
                   item_belongs.item_group_id = item_groups.id
                 inner join items on
                   items.id = item_belongs.item_id
                 inner join evaluation_categories on
                   evaluation_categories.id = items.evaluation_category_id
                 inner join evaluation_items on
                   evaluation_items.id = items.evaluation_item_id
                 left outer join scores on
                   scores.evaluation_id = evaluations.id
                   and scores.item_belong_id = item_belongs.id
                 left outer join points on
                   points.id = scores.point_id
                 inner join evaluation_orders on
                   evaluations.evaluation_order_id = evaluation_orders.id
                 where
                   (not(evaluation_orders.id in(:multifaceted)
                   and not(evaluation_categories.id in(:multifaceted_category))))
                   and (not(not(evaluation_orders.id in(:multifaceted))
                   and evaluation_categories.id in(:multifaceted_category)))
                   and users.id in(:user_ids)
                 group by users.id) incomplete_evaluations on
        incomplete_evaluations.id = users.id
      where
        users.id in(:user_ids)
      order by users.kana
    EOS
    users.collect do |user|
      if user.done == "t"
        def user.done
          true
        end
      elsif user.done == "f"
        def user.done
          false
        end
      else
        def user.done
          nil
        end
      end
      user
    end
  end

  def self.incompletes(*user_ids)
    find_by_sql([<<-EOS, {:user_ids => user_ids, :multifaceted => EvaluationOrder::Multifaceted.all, :multifaceted_category => EvaluationCategory::Multifaceted.all}])
      select
        users.name as user_name
      , users.kana as user_kana
      , object_users.name as object_user_name
      , object_users.kana as object_user_kana
      , evaluation_orders.name as evaluation_order_name
      , evaluation_items.name as evaluation_item_name
      from
        users
      inner join evaluations on
        evaluations.user_id = users.id
      inner join users object_users on
        object_users.id = evaluations.object_user_id
      inner join item_groups on
        item_groups.id = object_users.item_group_id
      inner join item_belongs on
        item_belongs.item_group_id = item_groups.id
      inner join items on
        items.id = item_belongs.item_id
      inner join evaluation_categories on
        evaluation_categories.id = items.evaluation_category_id
      inner join evaluation_items on
        evaluation_items.id = items.evaluation_item_id
      left outer join scores on
        scores.evaluation_id = evaluations.id
        and scores.item_belong_id = item_belongs.id
      left outer join points on
        points.id = scores.point_id
      inner join evaluation_orders on
        evaluations.evaluation_order_id = evaluation_orders.id
      where
        (not(evaluation_orders.id in(:multifaceted)
             and not(evaluation_categories.id in(:multifaceted_category))))
        and (not(not(evaluation_orders.id in(:multifaceted))
             and evaluation_categories.id in(:multifaceted_category)))
        and points.id is null
        #{user_ids.empty? ? "" : "and (users.id in(:user_ids))"}
      order by
        users.kana
      , object_users.kana
      , evaluation_orders.id
      , item_belongs.seq
    EOS
  end

  def self.incompletes_to_csv(*user_ids)
    CSV.generate do |csv|
      csv << [I18n.t('evaluator'), I18n.t('eval_targets'), I18n.t('category'), I18n.t('unevaluated_item')]
      self.incompletes(*user_ids).each do |e|
        csv << [
                e.user_name,
                e.object_user_name,
                e.evaluation_order_name,
                e.evaluation_item_name
               ]
      end
    end
  end

  def default_field
    self.login
  end

  def self.valid_field?(field)
    self.column_names.include?(field.to_s)
  end

  def self.set_long_name!(collection)
    collection.each do |user|
      def user.name
        "%s (%s)" % [attributes['name'], attributes['login']]
      end
      user
    end
  end

  protected



end
