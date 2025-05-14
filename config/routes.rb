# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq'
  resources :products, defaults: { format: :json }

  scope :cart, defaults: { format: :json } do
    post '/', to: 'carts#create'
    get '/', to: 'carts#show'
    post '/add_item', to: 'carts#add_item'
    delete '/:product_id', to: 'carts#remove_product'
  end
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'rails/health#show'
end
