# -*- coding: utf-8 -*-
class EvaluationTree::Multifaceted < EvaluationTree
  def self.description
    I18n.t('multifaceted_eval')
  end

  def self.evaluation_order_class
    EvaluationOrder::Multifaceted
  end

  def self.tranverse_recursively(current, callbacks={ }, parents=[], brothers=[], original_real_parents=[])
    children = current.last
    parent = parents.last
    pre_parent = (parents.length > 1) ? parents[parents.length - 2] : nil
    real_parent = select_real_parent(parents)

    current = self.find :first,
    :include => :user,
    :conditions => ["evaluation_trees.id = ?", current.first]

    unless current
      current = self.new
    end
    saved_parent = current.parent


    if parent and current.parent != parent
      # 親が変更されている
      original_real_parents << current.parent
      callbacks[:move_to].call current, parent, nil, (children.empty? ? current.to_sexpr_recursively { |e| e.id }.last : children)
      self.move_node current, parents, callbacks, brothers, real_parent, children

      if current.group? and children.empty? and current.new_record?
        # グループフォルダが移動となっているが、
        # 移動されたグループフォルダが閉じている場合
        children = current.to_sexpr_recursively { |e| e.id }.last
      end

    elsif parent and parent.group? and parent.parent != pre_parent
      # 親は変更されていないが
      # 親がグループフォルダでグループフォルダの親が変更されていた場合
      callbacks[:move_to].call current, parent, original_real_parents.last, (children.empty? ? current.to_sexpr_recursively { |e| e.id }.last : children)
      self.move_node current, parents, callbacks, brothers, real_parent, children

      if current.group? and children.empty? and current.new_record?
        # グループフォルダが移動となっているが、
        # 移動されたグループフォルダが閉じている場合
        children = current.to_sexpr_recursively { |e| e.id }.last
      end

    elsif !parent and current.parent
      # 以前は親がいたが、現状ではいない
      callbacks[:move_to].call current, nil, nil, (children.empty? ? current.to_sexpr_recursively { |e| e.id }.last : children)

      if current.group? and children.empty?
        # 閉じたグループフォルダがルートへ移動となっている場合
        children = current.to_sexpr_recursively { |e| e.id }.last
      end

    elsif current.new_record?
      self.move_node current, parents, callbacks, brothers, real_parent, children
    end

    if current.group? and children.length > 0 and children.length < 3 and real_parent
      self.make_children_no_round_robin children, real_parent, callbacks
    end

    if current
      self.make_node_active current, callbacks
    end

    current.instance_eval do
      @_original_parent = saved_parent
      def parent
        @_original_parent
      end
    end

    children.each do |child|
      self.tranverse_recursively child, callbacks, parents + [current], children, original_real_parents
    end
  end

  def self.remove_node(current, callbacks={ })
    callbacks[:removed].call current, nil
  end

  def self.move_node(current, parents=[], callbacks={ }, brothers=[], real_parent=nil, children=[])
    parent = parents.last

    if parent and parent.group?
      callbacks[:round_robin].call(current,
                                   parent,
                                   self.only_exactly_have_user.find_all_by_id(brothers.collect{|b| b.first}),
                                   real_parent)
    else
      callbacks[:added].call current, parent, brothers, real_parent, children
    end
  end

  def self.select_real_parent(parents)
    parents.length.times do |n|
      current = parents[parents.length - (n + 1)]
      if !current.group?
        return current
      end
    end
    nil
  end

  def self.remove_empty_groups
    self.no_user_assigned_only.each do |e|
      unless e.children?
        e.destroy
      end
    end
  end

  def self.make_node_active(current, callbacks)
    callbacks[:make_node_active].call current
  end

  def self.make_children_no_round_robin(brothers, real_parent, callbacks)
    brothers = self.only_exactly_have_user.find_all_by_id(brothers.collect {|brother| brother.first})
    callbacks[:make_children_no_round_robin].call brothers, real_parent
  end
end
