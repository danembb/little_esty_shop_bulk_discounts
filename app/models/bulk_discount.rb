class BulkDiscount < ApplicationRecord
  belongs_to :merchant

  validates :percentage_discount, presence: true, numericality: true
  validates :quantity_threshold, presence: true, numericality: true
end
