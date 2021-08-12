require 'rails_helper'

RSpec.describe 'merchant bulk discount index page' do
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

    visit merchant_bulk_discounts_path(@merchant1)
  end

  describe 'merchant bulk discounts index' do

#   As a merchant
#   When I visit the discounts index page
#   I see a section with a header of "Upcoming Holidays"
#   In this section the name and date of the next 3 upcoming US holidays are listed.
#   Use the Next Public Holidays Endpoint in the [Nager.Date API](https://date.nager.at/swagger/index.html)
    # xit 'can see upcoming holidays header' do
    #   expect(page).to have_content("Upcoming Holidays")
    # end

    # Merchant Bulk Discount Create
    # As a merchant x
    # When I visit my bulk discounts index x
    # Then I see a link to create a new discount x
    # When I click this link x
    # Then I am taken to a new page where I see a form to add a new bulk discount x
    # When I fill in the form with valid data x
    # Then I am redirected back to the bulk discount index x
    # And I see my new bulk discount listed x
    it 'can create a new bulk discount' do

      expect(page).to have_link("Create New Discount")

      click_on "Create New Discount"

      expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant1.id))
      expect(page).to have_content("Percentage Discount:")
      expect(page).to have_content("Quantity Threshold:")

      fill_in("percentage_discount", with: 35)
      fill_in("quantity_threshold", with: 50)

      click_on "Create Bulk Discount"

      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant1.id))
      expect(page).to have_content(35)
      expect(page).to have_content(50)
    end

    it 'has a link to each discount show page' do
      within "#discount#{@bulk_discount1.id}" do
        expect(page).to have_link("Discount #{@bulk_discount1.id} Show Page")
      end

      within "#discount#{@bulk_discount2.id}" do
        expect(page).to have_link("Discount #{@bulk_discount2.id} Show Page")
      end
    end

    it 'can display flash message error if the user fails to fill in the appropriate data' do
      visit new_merchant_bulk_discount_path(@merchant1.id)

      fill_in("percentage_discount", with: 60)

      click_on("Create Bulk Discount")

      expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant1.id))
      expect(page).to have_content("Please fill in valid information!")
    end

  # Merchant Bulk Discount Delete
  # As a merchant x
  # When I visit my bulk discounts index x
  # Next to each bulk discount I see a link to delete it x
  # When I click this link x
  # Then I am redirected back to the bulk discounts index page x
  # And I no longer see the discount listed x
    it 'can delete a bulk discount' do
      within("#discount#{@bulk_discount2.id}") do

        expect(page).to have_link("Delete This Discount")

        click_on "Delete This Discount"

        expect(current_path).to eq(merchant_bulk_discounts_path(@merchant1))
      end

    expect(page).to_not have_content("#{@bulk_discount2.id}")
    end
  end
end
