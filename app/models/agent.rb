class Agent < ApplicationRecord
  has_many :payments
  has_many :payment_export_logs
end
