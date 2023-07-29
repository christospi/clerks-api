Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'home#index'

  # Routes for "clerks" resource
  # GET /clerks
  resources :clerks, only: [:index]
end
