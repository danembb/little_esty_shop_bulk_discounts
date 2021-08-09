Rails.application.routes.draw do

  #-----Merchant---------------------------------------------------
  resources :merchant, only: [:show] do
    resources :dashboard, only: [:index]
    resources :items, except: [:destroy]
    resources :item_status, only: [:update]
    resources :invoices, only: [:index, :show, :update]
    resources :bulk_discounts, only: [:index, :new, :create, :show, :destroy]
    # dane, 8/7, how do i get this bulk_discounts nested in the merchant folder?
    # get '/merchant/bulk_discounts', to: 'merchant/bulk_discounts#index'
  end

  #-----Admin-----------------------------------------------------
  namespace :admin do
    resources :dashboard, only: [:index]
    resources :merchants, except: [:destroy]
    resources :merchant_status, only: [:update]
    resources :invoices, except: [:new, :destroy]
  end
end
