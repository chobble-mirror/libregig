Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Defines the root path route ("/")
  root "sessions#new"

  get "register", to: "users#new"
  post "register", to: "users#create"
  get "account", to: "users#edit"
  patch "account", to: "users#update"
  resources :users, only: [:show, :edit, :update]

  namespace :admin do
    resources :users, param: :username
    resources :bands
    post "impersonate", to: "impersonation#create"
    delete "impersonate", to: "impersonation#destroy"
    root to: "users#index"
  end

  resources :members
  resources :bands do
    get :confirm_destroy, on: :member
  end

  resources :events
  resources :user_mails, only: [:index, :create, :show]
  resources :sessions, only: [:new, :create, :destroy]
  resources :permissions, path: "/permissions"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "not_confirmed", to: "users/registration#edit"
  post "resend_confirmation", to: "users/registration#update"
  get "confirm_registration", to: "users/registration#new"
  post "confirm_registration_submit", to: "users/registration#create"
end
