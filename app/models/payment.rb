class Payment < ApplicationRecord
  belongs_to :agent
  belongs_to :contract

  scope :ready_for_export, -> { where(verified: true, cancelled: false) }
  scope :unprocessed, -> { where(processed: false) }
end
