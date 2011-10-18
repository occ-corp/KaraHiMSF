# -*- coding: utf-8 -*-

class Belong < ActiveRecord::Base
  belongs_to :user
  belongs_to :division
  belongs_to :job_title
  belongs_to :work_assignment
  validates_presence_of :user, :division
  validates_uniqueness_of :user_id, :scope => 'division_id'

  attr_accessible :job_title, :work_assignment, :user, :division, :primary_flag

  scope :order_by_job_title, lambda {
    {
      :include => :job_title,
      :order => "job_titles.id"
    }
  }

  def self.build_from_csv(file)
    collection = []
    CsvImporterUser.read_csv(file).each do |attributes|
      users = User.where(["replace(name, ' ', '') = ?", attributes[:name]])

      if users.count.zero?
        logger.warn "No such user. name:#{attributes[:name]}"
      elsif users.count > 1
        users = users.where(:code => attributes[:code])
        if users.count.zero?
          raise "No such user. name:#{attributes[:name]}, code:#{attributes[:code]}"
        elsif users.count > 1
          raise "Duplicated user. name:#{attributes[:name]}, code:#{attributes[:code]}"
        end
      end

      user = users.first

      division = Division.find_by_convenience_code(attributes[:division_code])
      unless division
        raise "No such division. convenience_code#{attributes[:division_code]}"
      end

      collection << Belong.new(:user => user, :division => division)
    end
    collection
  end

  def self.create_from_csv(file)
    build_from_csv(file).each do |belong|
      belong.save(:validation => false)
    end
  end

  def self.initialize_by_csv(file)
    file.seek(0)
    transaction do
      delete_all
      create_from_csv(file)
    end
  end
end
