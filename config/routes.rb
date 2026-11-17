Rails.application.routes.draw do
  root "pages#home"
  mount ActionCable.server => "/cable"

  resources :users, only: %i[new create]

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get "watchlist", to: "pages#watchlist", as: :watchlist

  resources :titles, only: :show do
    resource :watchlist, only: %i[create destroy], controller: :watchlist_items
    resources :reviews, only: %i[create update]
  end

  get "up", to: "rails/health#show", as: :rails_health_check
end
