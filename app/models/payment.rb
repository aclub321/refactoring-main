class Payment < ApplicationRecord
  belongs_to :agent
  belongs_to :contract

  def self.ready_for_export
    where(verified: true, cancelled: false)
  end
end
