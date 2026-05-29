Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :trademark_requests, only: :create
      resources :trademark_products, only: :index
      resources :cookie_consents, only: :create
      post "trademark_monitoring/search", to: "trademark_monitoring#search"
      resources :users, only: :create
      resource :session, only: %i[create show destroy]
      post "session/google", to: "sessions#google"
      get "account", to: "accounts#show"
      patch "account", to: "accounts#update"

      namespace :admin do
        get "dashboard", to: "dashboard#show"
        resources :trademark_requests, only: :update
        resources :trademark_products, only: %i[index create update destroy]
      end
    end
  end

  match "/api/v1/*path", to: "api/v1/preflight#show", via: :options

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
