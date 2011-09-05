# -*- coding: utf-8 -*-

class System < ActiveRecord::Base
  validates_presence_of :implementation_term_start_at,
                        :implementation_term_finish_at,
                        :evaluation_term_start_at,
                        :evaluation_term_finish_at

  def self.system
    self.first
  end

  def describe_implementation_term
    implementation_term_start_at.strftime('%Y/%m/%d %H:%M') + ' - ' +
      implementation_term_finish_at.strftime('%Y/%m/%d %H:%M')
  end

  def describe_evaluation_term
      evaluation_term_start_at.strftime('%Y/%m/%d') + ' - ' +
        evaluation_term_finish_at.strftime('%Y/%m/%d')
  end

  def self.describe_implementation_term
    if (system = self.class.first)
      system.describe_implementation_term
    end
  end

  def self.describe_evaluation_term
    if (system = self.class.first)
      system.describe_evaluation_term
    end
  end

  def self.describe_implementation_term
    if (system = self.first)
      system.describe_implementation_term
    end
  end

  def self.describe_evaluation_term
    if (system = self.first)
      system.describe_evaluation_term
    end
  end

  def self.evaluation_closed?
    if (system = self.first)
      system.evaluation_closed
    end
  end

  def self.evaluation_published_managers?
    if (system = self.first)
      system.evaluation_published_managers
    end
  end

  def self.evaluation_published_employees?
    if (system = self.first)
      system.evaluation_published_employees
    end
  end

  def self.questionnaire_executed?
    if (system = self.first)
      system.questionnaire_executed
    end
  end
end
