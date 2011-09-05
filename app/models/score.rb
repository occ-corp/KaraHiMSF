# -*- coding: utf-8 -*-

class Score < ActiveRecord::Base
  belongs_to :evaluation
  belongs_to :item_belong
  belongs_to :point

  def to_hash_for_json
    self.attributes.merge([
                           :evaluation_item_name
                          ].inject({}) { |attrs, field|
                            attrs.merge({field => self.send(field)})
                          })
  end

  def evaluation_item_name
    item_belong.item.evaluation_item.name
  rescue NoMethodError => e
  end

  def self.update_by_params(params)
    params.each do |object_user_id, scores|
      scores.each do |item_id, attrs|
        if attrs[:id].to_s.empty?
          score = nil
        else
          score = find_by_id attrs[:id]
        end
        if score
          score.update_attributes! attrs
        else
          create! attrs
        end
      end
    end
  end
end
