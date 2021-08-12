class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :merchants

  enum status: [:cancelled, 'in progress', :completed]

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def discounted_revenue(model_invoice_items)
    accumulated_revenue = 0

    model_invoice_items.each do |ii|
      if ii.qualified_for_discount? == false
        accumulated_revenue += (ii.quantity * ii.unit_price)
      else
        accumulated_revenue += ((ii.quantity * ii.unit_price) - ((ii.quantity * ii.unit_price) * (ii.max_discount_for_quantity(ii.quantity) / 100.00)))
      end
    end
    accumulated_revenue
  end
end
