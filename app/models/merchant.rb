class Merchant < ApplicationRecord
  validates_presence_of :name
  has_many :items
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices
  has_many :bulk_discounts

  enum status: [:enabled, :disabled]

  def favorite_customers
    transactions
    .joins(invoice: :customer)
    .where('result = ?', 1)
    .select("customers.*, count('transactions.result') as top_result")
    .group('customers.id')
    .order(top_result: :desc)
    .limit(5)
  end

  def ordered_items_to_ship
    item_ids = InvoiceItem.where("status = 0 OR status = 1").order(:created_at).pluck(:item_id)
    item_ids.map do |id|
      Item.find(id)
    end
  end

  def top_5_items
     items
     .joins(invoices: :transactions)
     .where('transactions.result = 1')
     .select("items.*, sum(invoice_items.quantity * invoice_items.unit_price) as total_revenue")
     .group(:id)
     .order('total_revenue desc')
     .limit(5)
   end

  def self.top_merchants
    joins(invoices: [:invoice_items, :transactions])
    .where('result = ?', 1)
    .select('merchants.*, sum(invoice_items.quantity * invoice_items.unit_price) AS total_revenue')
    .group(:id)
    .order('total_revenue DESC')
    .limit(5)
  end

  def best_day
    if
      invoices
      .where("invoices.status = 2")
      .joins(:invoice_items)
      .empty?
      return 0
    else
      invoices
      .select('invoices.created_at, sum(invoice_items.unit_price * invoice_items.quantity) as revenue')
      .group("invoices.created_at")
      .order("revenue desc", "created_at desc")
      .first
      .created_at
      .to_date
    end
  end

  def minimum_quantity_for_discount
    bulk_discounts.minimum(:quantity_threshold)
  end

  def max_discount_for_quantity(quantity)
    bulk_discounts
    .where('quantity_threshold <= ?', quantity)
    .maximum(:percentage_discount)
  end

  def total_discounted_revenue(invoice)
    discounted_revenue = 0

    merchants_invoice_items = self.invoice_items
    .where('invoice_id = ?', invoice)

    merchants_invoice_items.each do |ii|
      if ii.quantity >= self.minimum_quantity_for_discount

        discounted_revenue += ((ii.quantity * ii.unit_price) - ((ii.quantity * ii.unit_price) * (self.max_discount_for_quantity(ii.quantity) / 100.00)))
      else
        discounted_revenue += (ii.quantity * ii.unit_price)
      end
    end
    discounted_revenue
  end
end
