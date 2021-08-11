class BulkDiscountsController < ApplicationController

  def index
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discounts = @merchant.bulk_discounts
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.new({
    percentage_discount: params[:percentage_discount],
    quantity_threshold: params[:quantity_threshold],
    merchant_id: @merchant.id
    })
    if @bulk_discount.save
      redirect_to merchant_bulk_discounts_path(@merchant)
    else
      redirect_to new_merchant_bulk_discount_path
      flash[:notice] = "Please fill in valid information!"
    end
  end

  def show
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def destroy
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = @merchant.bulk_discounts.destroy(params[:id])

    redirect_to merchant_bulk_discounts_path(@merchant)
  end

  def edit
  @merchant = Merchant.find(params[:merchant_id])
  @bulk_discount = BulkDiscount.find(params[:id])
  end

  def update
  @merchant = Merchant.find(params[:merchant_id])
  @bulk_discount = BulkDiscount.find(params[:id])
  @bulk_discount.update(discount_params)
    if @bulk_discount.save
      redirect_to merchant_bulk_discount_path(@merchant)
    else
      redirect_to edit_merchant_bulk_discount_path(@merchant, @bulk_discount)
      flash[:notice] = "Please fill in valid information!"
    end
  end

  private

  def discount_params
    params.permit(:percentage_discount, :quantity_threshold)
  end
end
