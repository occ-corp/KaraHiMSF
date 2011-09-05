class Interview < ActiveRecord::Base
  belongs_to :evaluation

  def done?
    !self.done_at.nil?
  end
end
