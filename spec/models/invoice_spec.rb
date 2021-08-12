require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end
  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many :transactions}
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many(:bulk_discounts).through(:merchants) }
  end
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')
    @merchant2 = Merchant.create!(name: 'Jewelry')

    @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
    @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)

    @item_9 = Item.create!(name: "Super Star", description: "Its-a-me", unit_price: 100, merchant_id: @merchant2.id)

    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')

    @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
    @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2)

    @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
    @ii_2 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0, created_at: "2012-03-29 14:54:09")
    @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)
    @ii_14 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_9.id, quantity: 29, unit_price: 100, status: 1)

    @merchants_invoice_items = @merchant1.invoice_items.where('invoice_id = ?', @invoice_1.id)
    @invoices_invoice_items1 = @invoice_1.invoice_items
    @invoices_invoice_items2 = @invoice_2.invoice_items

    @bulk_discount1 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 8)
    @bulk_discount2 = @merchant1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 20)
    @bulk_discount3 = @merchant1.bulk_discounts.create!(percentage_discount: 5, quantity_threshold: 30)
  end
  describe "instance methods" do
    it "total_revenue" do

      expect(@invoice_1.total_revenue).to eq(100)
    end

    it "#discounted_revenue(model_invoice_items)" do

      expect(@invoice_1.discounted_revenue(@invoices_invoice_items1)).to eq(82.0)
      expect(@invoice_2.discounted_revenue(@invoices_invoice_items2)).to eq(2910.0)
    end
  end
end
