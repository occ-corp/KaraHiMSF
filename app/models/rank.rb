# -*- coding: utf-8 -*-

class Rank
  RANK_TABLE = [
                {
                  :name        => 'rank_a_label',
                  :description => 'rank_a_cond_label',
                  :proc        => lambda { |p| p >= 84 },
                  :javascript => "p >= 84"
                },
                {
                  :name        => 'rank_b_upper_label',
                  :description => 'rank_b_upper_cond_label',
                  :proc        => lambda { |p| p < 84 && p >= 80 },
                  :javascript => "p < 84 && p >= 80"
                },
                {
                  :name        => 'rank_b_middle_label',
                  :description => 'rank_b_middle_cond_label',
                  :proc        => lambda { |p| p < 80 && p >= 72 },
                  :javascript => "p < 80 && p >= 72"
                },
                {
                  :name        => 'rank_b_lower_label',
                  :description => 'rank_b_lower_cond_label',
                  :proc        => lambda { |p| p < 72 && p >= 68 },
                  :javascript => "p < 72 && p >= 68"
                },
                {
                  :name        => 'rank_c_upper_label',
                  :description => 'rank_c_upper_cond_label',
                  :proc        => lambda { |p| p < 68 && p >= 64 },
                  :javascript => "p < 68 && p >= 64"
                },
                {
                  :name        => 'rank_c_middle_label',
                  :description => 'rank_c_middle_cond_label',
                  :proc        => lambda { |p| p < 64 && p >= 56 },
                  :javascript => "p < 64 && p >= 56"
                },
                {
                  :name        => 'rank_c_lower_label',
                  :description => 'rank_c_lower_cond_label',
                  :proc        => lambda { |p| p < 56 && p >= 52 },
                  :javascript => "p < 56 && p >= 52"
                },
                {
                  :name        => 'rank_d_upper_label',
                  :description => 'rank_d_upper_cond_label',
                  :proc        => lambda { |p| p < 52 && p >= 48 },
                  :javascript => "p < 52 && p >= 48"
                },
                {
                  :name        => 'rank_d_middle_label',
                  :description => 'rank_d_middle_cond_label',
                  :proc        => lambda { |p| p < 48 && p >= 40 },
                  :javascript => "p < 48 && p >= 40"
                },
                {
                  :name        => 'rank_d_lower_label',
                  :description => 'rank_d_lower_cond_label',
                  :proc        => lambda { |p| p < 40 && p >= 36 },
                  :javascript => "p < 40 && p >= 36"
                },
                {
                  :name        => 'rank_e_label',
                  :description => 'rank_e_cond_label',
                  :proc        => lambda { |p| p < 36 },
                  :javascript => "p < 36"
                },
               ]

  attr_accessor :name, :description, :proc

  def initialize(args={ })
    @name = I18n.t(args[:name])
    @description = I18n.t(args[:description])
    @proc = args[:proc]
  end

  def self.all
    if defined?(@@rank_table)
      @@rank_table
    else
      @@rank_table = RANK_TABLE.collect do |args|
        Rank.new args
      end
    end
  end

  def self.find_by_score(score)
    all.select {|rank| rank.proc.call(score.to_f) ? true : false}.first
  end

  def self.find_by_rank(name)
    all.select {|rank| rank.name == name.to_s ? true : false}.first
  end
end
