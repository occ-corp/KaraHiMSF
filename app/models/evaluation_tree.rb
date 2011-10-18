# -*- coding: utf-8 -*-
class EvaluationTree < ActiveRecord::Base
  acts_as_nested_set

  belongs_to :user
  belongs_to :head, :foreign_key => :head_id, :class_name => EvaluationTree.to_s

  accepts_nested_attributes_for :user

  scope :including_user, lambda {
    {
      :include => :user
    }
  }

  scope :selected_only, lambda {
    {
      :conditions => "evaluation_trees.selected is true"
    }
  }

  scope :without_excluded, lambda { |with_excluded|
    if with_excluded == 'true'
      nil
    else
      {
        :include => :user,
        :conditions => ["users.excluded is not true"]
      }
    end
  }

  scope :order_by_user_kana, lambda {
    {
      :include => :user,
      :order => "users.kana"
    }
  }

  scope :only_exactly_have_user, lambda {
    {
      :conditions => ["evaluation_trees.user_id is not null"]
    }
  }

  scope :no_user_assigned_only, lambda {
    {
      :conditions => ["evaluation_trees.user_id is null"]
    }
  }

  scope :order_by_lft, lambda {
    {
      :order => self.prefixed_left_col_name
    }
  }

  scope :find_all_by_csv_ids, lambda { |csv_ids|
    {
      :conditions => ['evaluation_trees.id in(?)', csv_ids.to_s.split(',')]
    }
  }

  scope :disabled_only, lambda { |boolean, pending_disablings|
    if boolean.to_s == 'true'
      if pending_disablings.is_a?(String)
        pending_disablings = pending_disablings.to_s.split(',')
      end
      if pending_disablings.empty?
        {
          :conditions => ["evaluation_trees.selected = ?", false],
        }
      else
        {
          :conditions => ["evaluation_trees.selected = ? or evaluation_trees.id in(?)", false, pending_disablings],
        }
      end
    end
  }

  scope :scope_by_phrase, lambda {  |phrase|
    count = 0
    phrases = phrase.to_s.gsub(/　/, ' ').split(/\s+/).inject({ }) { |h, p|
      h.merge({ "phrase#{count += 1}".to_sym => "%#{p}%" })
    }
    {
      :include => :user,
      :conditions => [
                      phrases.keys.collect {  |p|
                        "(%s)" %
                        [
                         "users.login",
                         "users.email",
                         "users.name",
                         "users.kana",
                         "users.code",
                         "users.note",
                        ].collect {  |f|
                          "(#{ f} like :#{ p})"
                        }.join(' or ')
                      }.join(' and '),
                      phrases
                     ]
    }
  }

  scope :topdown_only, lambda {
    {
      :conditions => ["evaluation_trees.type = ?", EvaluationTree::TopDown.to_s]
    }
  }

  def to_sexpr_recursively(&block)
    [
     block ? block.call(self) : self,
     (self.new_record? ? [] : self.children).collect do |subtree|
       subtree.to_sexpr_recursively &block
     end
    ]
  end

  def to_sexpr(&block)
    [block ? block.call(self) : self, []]
  end

  def to_sexpr_path_recursivery(a)
    cons = [a]
    if a.parent
      cons.concat(to_sexpr_path_recursivery(a.parent))
    else
      cons
    end
  end

  def to_sexpr_path(&block)
    if self.parent
      to_sexpr_path_recursivery(self.parent).collect { |t| block ? block.call(t) : t }.reverse
    else
      []
    end
  end

  def self.find_by_user_login(login)
    self.find :first, :include => :user, :conditions => ["users.login = ?", login]
  end

  def self.to_sexpr(&block)
    self.roots(:conditions => ["type = ? and evaluation_trees.selected = ?",
                               self.to_s,
                               true]).collect do |t|
      [block ? block.call(t): self, []]
    end
  end

  def user_name
    if user
      user.name
    end
  end

  def user_code
    if user
      user.code
    end
  end

  def has_children
    self.children?
  end

  def excluded
    if user
      user.excluded
    end
  end

  def note
    if user
      user.note
    end
  end

  def user_id
    if user
      user.id
    end
  end

  def to_hash_for_json
    [
     :id,
     :user_name,
     :user_code,
     :user_id,
     :excluded,
     :note,
     :selected,
     :has_children,
    ].inject({ }) do |attrs, field|
      attrs.merge({field => self.send(field)})
    end
  end

  def move_root
    unless self.root?
      self.move_to_right_of self.class.roots.last
    end
  end

  def self.to_csv(field, with_note=false, *options)
    CSV.generate do |csv|
      if with_note
        csv << [I18n.t('eval_group_id'), I18n.t('eval_flag'), I18n.t('excluded_flag'), I18n.t('employee_id2'), I18n.t('employee_name'), I18n.t('department'), I18n.t('job_title'), I18n.t('job'), I18n.t('division_lft'), I18n.t('note'), I18n.t('login')]
      else
        csv << [I18n.t('eval_group_id'), I18n.t('eval_flag'), I18n.t('excluded_flag'), I18n.t('employee_id2'), I18n.t('employee_name'), I18n.t('department'), I18n.t('job_title'), I18n.t('job'), I18n.t('division_lft'), I18n.t('login')]
      end
      self.order_by_lft.all(*options).each do |e|
        a = [e.id, (!e.selected ? "FALSE" : nil), (e.excluded ? "TRUE" : nil)]
        if e.user
          user = e.user
          a.concat([user.code, user.name])
          belong = e.user.belongs.first
          if belong and (d = belong.division)
            a << ('  ' * d.level + d.name)
          else
            a << nil
          end
          if belong and belong.job_title
            a << belong.job_title.name
          else
            a << nil
          end
          item_group = user.item_group
          if item_group
            a << item_group.name
          else
            a << nil
          end
          if belong and belong.division
            a << belong.division.lft
          else
            a << nil
          end
          if with_note
            a.concat([e.note])
          end
        else
          if with_note
            a.concat([nil, I18n.t('multifaceted_eval_group'), nil, nil, nil, nil, nil])
          else
            a.concat([nil, I18n.t('multifaceted_eval_group'), nil, nil, nil, nil])
          end
        end
        e.level.times do
          a << nil
        end
        a << (e.user ? (User.valid_field?(field) ? e.user.send(field) : e.user.default_field) : ("group"))
        csv << a
      end
    end
  end

  def self.description
    ""
  end

  def group?
    user.nil?
  end

  def self.evaluation_order_class
    raise "abstract method"
  end

  def self.tranverse(current, callbacks={ })
    default_callbacks = {
      :removed => lambda { |current, parent| },
      :added => lambda { |current, parent| },
      :round_robin => lambda { |current, parent, brothers, real_parent| },
      :make_node_active => lambda { |current| },
      :make_children_no_round_robin => lambda { |brothers, real_parent| },
    }
    self.tranverse_recursively(current, default_callbacks.merge(callbacks.symbolize_keys))
  end

  def self.tranverse_recursively(current, callbacks={ }, parent=nil)
    raise "abstract method"
  end

  def self.remove(current, callbacks={ })
    callbacks.symbolize_keys!
    default_callbacks = {
      :removed => lambda { |current, parent| },
    }.merge(callbacks)
    default_callbacks[:removed].call current, nil
  end


  def self.remove_empty_groups
  end
end
