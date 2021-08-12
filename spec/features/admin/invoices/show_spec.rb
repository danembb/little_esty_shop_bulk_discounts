require 'rails_helper'

describe 'Admin Invoices Index Page' do
  before :each do
    @m1 = Merchant.create!(name: 'Merchant 1')
    @m2 = Merchant.create!(name: 'Merchant 2')

    @c1 = Customer.create!(first_name: 'Yo', last_name: 'Yoz', address: '123 Heyyo', city: 'Whoville', state: 'CO', zip: 12345)
    @c2 = Customer.create!(first_name: 'Hey', last_name: 'Heyz')

    @i1 = Invoice.create!(customer_id: @c1.id, status: 2, created_at: '2012-03-25 09:54:09')
    @i2 = Invoice.create!(customer_id: @c2.id, status: 1, created_at: '2012-03-25 09:30:09')
    @i3 = Invoice.create!(customer_id: @c2.id, status: 1, created_at: '2012-03-25 09:30:09')

    @item_1 = Item.create!(name: 'test', description: 'lalala', unit_price: 6, merchant_id: @m1.id)
    @item_2 = Item.create!(name: 'rest', description: 'dont test me', unit_price: 12, merchant_id: @m1.id)
    @item_6 = Item.create!(name: "Necklace", description: "Neck bling", unit_price: 300, merchant_id: @m2.id)
    @item_9 = Item.create!(name: "Super Star", description: "Its-a-me", unit_price: 100, merchant_id: @m2.id)

    @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 12, unit_price: 2, status: 0)
    @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 6, unit_price: 1, status: 1)
    @ii_3 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_2.id, quantity: 87, unit_price: 12, status: 2)
    @ii_4 = InvoiceItem.create!(invoice_id: @i3.id, item_id: @item_2.id, quantity: 15, unit_price: 12, status: 2)
    @ii_5 = InvoiceItem.create!(invoice_id: @i3.id, item_id: @item_6.id, quantity: 1, unit_price: 300, status: 2)
    @ii_6 = InvoiceItem.create!(invoice_id: @i3.id, item_id: @item_9.id, quantity: 30, unit_price: 100, status: 2)

    @invoices_invoice_items1 = @i1.invoice_items
    @invoices_invoice_items2 = @i3.invoice_items

    @bulk_discount1 = @m1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 8)
    @bulk_discount2 = @m1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 20)
    @bulk_discount3 = @m1.bulk_discounts.create!(percentage_discount: 5, quantity_threshold: 30)
    @bulk_discount4 = @m2.bulk_discounts.create!(percentage_discount: 15, quantity_threshold: 15)
    @bulk_discount5 = @m2.bulk_discounts.create!(percentage_discount: 25, quantity_threshold: 30)


  end

  it 'should display the id, status and created_at' do
    visit admin_invoice_path(@i1)
    expect(page).to have_content("Invoice ##{@i1.id}")
    expect(page).to have_content("Created on: #{@i1.created_at.strftime("%A, %B %d, %Y")}")

    expect(page).to_not have_content("Invoice ##{@i2.id}")
  end

  it 'should display the customers name and shipping address' do
    visit admin_invoice_path(@i1)
    expect(page).to have_content("#{@c1.first_name} #{@c1.last_name}")
    expect(page).to have_content(@c1.address)
    expect(page).to have_content("#{@c1.city}, #{@c1.state} #{@c1.zip}")

    expect(page).to_not have_content("#{@c2.first_name} #{@c2.last_name}")
  end

  it 'should display all the items on the invoice' do
    visit admin_invoice_path(@i1)
    expect(page).to have_content(@item_1.name)
    expect(page).to have_content(@item_2.name)

    expect(page).to have_content(@ii_1.quantity)
    expect(page).to have_content(@ii_2.quantity)

    expect(page).to have_content("$#{@ii_1.unit_price}")
    expect(page).to have_content("$#{@ii_2.unit_price}")

    expect(page).to have_content(@ii_1.status)
    expect(page).to have_content(@ii_2.status)

    expect(page).to_not have_content(@ii_3.quantity)
    expect(page).to_not have_content("$#{@ii_3.unit_price}")
    expect(page).to_not have_content(@ii_3.status)
  end

  it 'should display the total revenue the invoice will generate' do
    visit admin_invoice_path(@i1)
    expect(page).to have_content("Total Revenue: $#{@i1.total_revenue}")

    expect(page).to_not have_content(@i2.total_revenue)
  end

  it 'should have status as a select field that updates the invoices status' do
    visit admin_invoice_path(@i1)
    within("#status-update-#{@i1.id}") do
      select('cancelled', :from => 'invoice[status]')
      expect(page).to have_button('Update Invoice')
      click_button 'Update Invoice'

      expect(current_path).to eq(admin_invoice_path(@i1))
      expect(@i1.status).to eq('completed')
    end
  end

  # Admin Invoice Show Page: Total Revenue and Discounted Revenue
  # As an admin x x
  # When I visit an admin invoice show page x x
  # Then I see the total revenue from THIS invoice (not including discounts) x x
  # And I see the total discounted revenue from THIS invoice which includes bulk discounts in the calculation x
  it 'can see the total revenue and the total discounted revenue including bulk discount in-calculation for invoice 1' do
    visit admin_invoice_path(@i1)

    expect(page).to have_content(@i1.total_revenue)
    expect(page).to have_content(@i1.discounted_revenue(@invoices_invoice_items1))
  end

  it 'can see the total revenue and the total discounted revenue including bulk discount in-calculation for invoice 3' do
    visit admin_invoice_path(@i3)

    expect(page).to have_content(@i3.total_revenue)
    expect(page).to have_content(@i3.discounted_revenue(@invoices_invoice_items2))
  end
end
