class InvoiceItem < ApplicationRecord
  validates_presence_of :invoice_id,
                        :item_id,
                        :quantity,
                        :unit_price,
                        :status

  belongs_to :invoice
  belongs_to :item
  has_one :merchant, through: :item
  has_many :bulk_discounts, through: :merchant

  enum status: [:pending, :packaged, :shipped]

  def self.incomplete_invoices
    invoice_ids = InvoiceItem.where("status = 0 OR status = 1").pluck(:invoice_id)
    Invoice.order(created_at: :asc).find(invoice_ids)
  end

  def meets_threshold
    bulk_discounts.where('bulk_discounts.quantity_threshold <= ?', self.quantity)
    .order('bulk_discounts.percentage_discount desc')
    .first
  end

  def qualified_for_discount?
    merchant = Merchant.where('id = ?', item.merchant_id).first
    if merchant.bulk_discounts.empty?
      false
    else
      self.quantity >= bulk_discounts.minimum(:quantity_threshold)
    end
  end

  def max_discount_for_quantity(quantity)
    bulk_discounts
    .where('quantity_threshold <= ?', quantity)
    .maximum(:percentage_discount)
  end
end
