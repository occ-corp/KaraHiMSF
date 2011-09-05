# -*- coding: utf-8 -*-

class Division < ActiveRecord::Base
  acts_as_nested_set

  has_many :belongs, :dependent => :destroy
  has_many :users, :through => :belongs
  accepts_nested_attributes_for :belongs, :allow_destroy => true
  attr_accessible :belongs_attributes, :name, :code, :fiscal_code, :convenience_code

  scope :organized, lambda {
    {
      :order => order_for_organizing
    }
  }

  def full_path(division=self)
    path = [division]
    division.parent ? path.concat(full_path(division.parent)) : path
  end

  def nested_name
    ('　' * level) + name
  end

  def self.order_for_organizing
    'divisions.lft'
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << [I18n.t('department_id'), I18n.t('employee_id2'), I18n.t('employee_code'), I18n.t('employee_name'), I18n.t('job_title'), I18n.t('job_category'), I18n.t('note'), "users.login or divisions.name"]

      self.find(:all, :order => self.prefixed_left_col_name).each do |d|
        a = [d.id, nil, nil, nil, nil, nil, nil]
        d.level.times do
          a << nil
        end
        a << I18n.t(:division_name_label, :name => d.name)
        csv << a

        d.belongs.order_by_job_title.each do |belong|
          user = belong.user
          a = [nil, user.id, user.code, user.name, (belong.job_title ? belong.job_title.name : nil), (belong.work_assignment ? belong.work_assignment.name : nil), user.note]
          (d.level).times do
            a << nil
          end
          if belong.work_assignment and belong.work_assignment.name==I18n.t('officer')
            a << I18n.t('double_star') + user.login

          elsif belong.work_assignment and belong.work_assignment.name==I18n.t('managerial_position')
            a << I18n.t('single_star') + user.login
          else
            a <<  user.login
          end
          csv << a
        end
      end
    end
  end

  def self.build_if_no_exist_from_csv(file)
    collection = []
    CsvImporterDivision.read_csv(file).each do |attributes|
      division = Division.find_by_convenience_code_and_name(attributes[:convenience_code], attributes[:name])
      unless division
        collection << Division.new(:name => attributes[:name],
                                   :code => attributes[:code],
                                   :fiscal_code => attributes[:fiscal_code],
                                   :convenience_code => attributes[:convenience_code])
      end
    end
    collection
  end

  def self.create_from_csv(file)
    build_if_no_exist_from_csv(file).each do |division|
      division.save!
    end
  end

  def self.find_parent_by_convenience_code_recursively(code)
    division = find_by_convenience_code(code)
    if division
      division
    else
      parent_code = CsvImporterDivision.guess_parent_code(code)
      if parent_code != code
        find_parent_by_convenience_code_recursively(parent_code)
      end
    end
  end

  def self.restructure_by_code
    all.each do |division|
      if division.code == division.convenience_code
        parent = find_by_convenience_code(division.fiscal_code)
      elsif !(division.fiscal_code == division.code and division.code == division.convenience_code)
        parent = find_parent_by_convenience_code_recursively(CsvImporterDivision.guess_parent_code(division.convenience_code))
      end
      if parent and parent.id != division.id
        division.move_to_child_of(parent)
      end
    end
  end

  def self.initialize_by_csv(file)
    file.seek(0)
    transaction do
      delete_all
      create_from_csv(file)
      restructure_by_code
    end
  end
end
