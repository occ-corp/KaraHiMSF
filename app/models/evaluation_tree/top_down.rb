# -*- coding: utf-8 -*-
class EvaluationTree::TopDown < EvaluationTree
  def self.description
    I18n.t('topdown_eval')
  end

  def self.evaluation_order_class
    EvaluationOrder::TopDown
  end

  def self.tranverse_recursively(current, callbacks={ }, parent=nil, original_parent_parent=nil)
    children = current.last
    current = self.find :first,
    :include => :user,
    :conditions => ["evaluation_trees.id = ?", current.first]
    saved_original_parent_parent = current.parent
    if parent and current.parent != parent
      # 親が変更されている場合
      callbacks[:removed].call(current, parent)
      callbacks[:added].call(current, parent, [], nil, [])
      if children.empty?
        # サブツリーが畳まれていた場合
        children = current.to_sexpr_recursively { |e| e.id }.last
      end
    elsif !parent and current.parent
      # 以前は親がいたが現状ではいない
      callbacks[:removed].call(current, current.parent)
      if children.empty?
        # サブツリーが畳まれていた場合
        children = current.to_sexpr_recursively { |e| e.id }.last
      end
    elsif (current.parent and current.parent.parent != original_parent_parent) or
        (original_parent_parent and !current.parent)
      # 親の親が変更されている場合
      # callbacks[:remove_parent_parent].call(current, original_parent_parent)
      #callbacks[:add_parent_parent].call
      callbacks[:removed].call(current, parent)
      callbacks[:added].call(current, parent, [], nil, [])
    end
    if current
      callbacks[:make_node_active].call(current)
    end
    children.each do |child|
      self.tranverse_recursively child, callbacks, current, saved_original_parent_parent
    end
  end
end
