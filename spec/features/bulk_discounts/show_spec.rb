require 'rails_helper'

RSpec.describe 'merchant bulk discount show page' do
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')

    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
    @customer_2 = Customer.create!(first_name: 'Cecilia', last_name: 'Jones')
    @customer_3 = Customer.create!(first_name: 'Mariah', last_name: 'Carrey')
    @customer_4 = Customer.create!(first_name: 'Leigh Ann', last_name: 'Bron')
    @customer_5 = Customer.create!(first_name: 'Sylvester', last_name: 'Nader')
    @customer_6 = Customer.create!(first_name: 'Herber', last_name: 'Coon')

    @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    @invoice_3 = Invoice.create!(customer_id: @customer_2.id, status: 2)
    @invoice_4 = Invoice.create!(customer_id: @customer_3.id, status: 2)
    @invoice_5 = Invoice.create!(customer_id: @customer_4.id, status: 2)
    @invoice_6 = Invoice.create!(customer_id: @customer_5.id, status: 2)
    @invoice_7 = Invoice.create!(customer_id: @customer_6.id, status: 1)

    @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id)
    @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
    @item_3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: @merchant1.id)
    @item_4 = Item.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1, merchant_id: @merchant1.id)

    @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
    @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
    @ii_3 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
    @ii_4 = InvoiceItem.create!(invoice_id: @invoice_3.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)

    @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)
    @transaction2 = Transaction.create!(credit_card_number: 230948, result: 1, invoice_id: @invoice_3.id)
    @transaction3 = Transaction.create!(credit_card_number: 234092, result: 1, invoice_id: @invoice_4.id)
    @transaction4 = Transaction.create!(credit_card_number: 230429, result: 1, invoice_id: @invoice_5.id)
    @transaction5 = Transaction.create!(credit_card_number: 102938, result: 1, invoice_id: @invoice_6.id)
    @transaction6 = Transaction.create!(credit_card_number: 879799, result: 1, invoice_id: @invoice_7.id)
    @transaction7 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_2.id)

    @bulk_discount1 = @merchant1.bulk_discounts.create!(percentage_discount: 15, quantity_threshold: 8)
    @bulk_discount2 = @merchant1.bulk_discounts.create!(percentage_discount: 30, quantity_threshold: 20)

    visit merchant_bulk_discount_path(@merchant1, @bulk_discount1)
  end

  # Merchant Bulk Discount Show
  # As a merchant x
  # When I visit my bulk discount show page x
  # Then I see the bulk discount's quantity threshold and percentage discount x
  it 'can see the bulk discounts attributes' do

    expect(page).to have_content(@bulk_discount1.percentage_discount)
    expect(page).to have_content(@bulk_discount1.quantity_threshold)
  end

  # Merchant Bulk Discount Edit
  # As a merchant x
  # When I visit my bulk discount show page x
  # Then I see a link to edit the bulk discount x
  # When I click this link x
  # Then I am taken to a new page with a form to edit the discount x
  # And I see that the discounts current attributes are pre-populated in the form x
  # When I change any/all of the information and click submit x
  # Then I am redirected to the bulk discount's show page x
  # And I see that the discount's attributes have been updated x
  it 'can edit a bulk discount' do
    expect(page).to have_link("Edit This Discount")

    click_on("Edit This Discount")

    expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant1, @bulk_discount1))
    expect(page).to have_content("Percentage Discount:")
    expect(page).to have_content("Quantity Threshold:")
    expect(page).to have_content(@bulk_discount1.id)
    expect(find_field(:percentage_discount).value).to eq(@bulk_discount1.percentage_discount.to_s)
    expect(find_field(:quantity_threshold).value).to eq(@bulk_discount1.quantity_threshold.to_s)

    fill_in("percentage_discount", with: 20)
    fill_in("quantity_threshold", with: 16)

    click_on "Update Discount"
    
    expect(current_path).to eq(merchant_bulk_discount_path(@merchant1, @bulk_discount1))
    expect(page).to have_content(20)
    expect(page).to have_content(16)
  end

  it 'redirects back to edit page if no information is entered' do
    visit edit_merchant_bulk_discount_path(@merchant1, @bulk_discount1)

    fill_in("percentage_discount", with: 100)
    fill_in("percentage_discount", with: "")

    click_on "Update Discount"

    expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant1, @bulk_discount1))
    expect(page).to have_content("Please fill in valid information!")
  end
end
