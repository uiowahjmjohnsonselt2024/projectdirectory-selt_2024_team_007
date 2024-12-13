Rails.application.routes.draw do
  get "legal_compliance/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  #
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  mount ActionCable.server => '/cable'
  resources :channels
  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  get '/favicon.ico', to: redirect('/assets/favicon.ico')


  # Register path
  get '/register', to: 'users#new', as: 'register'
  post "/register", to: 'users#create'

  # Login routes
  get '/login_firsttime', to: 'sessions#login_firsttime'  # only for the first time access the page
  get '/login', to: 'sessions#new', as: 'login'
  post '/login', to: 'sessions#create'

  # Legal compliance routes
  get 'legal_compliance', to: 'legal_compliance#index'

  # 3rd party login redirect
  post '/auth/:provider', to: 'sessions#oauth_request', as: 'oauth_request'
  get '/auth/:provider/callback', to: 'sessions#oauth_create', as: 'oauth_create'
  get '/auth/failure', to: redirect('/login')
  #get '/auth/:provider', to: proc { [404, {}, ['404 - OmniAuth provider not found!']] }, via: [:get, :post]

  get '/landing', to: 'landing#index', as: 'landing'
  get 'settings', to: 'settings#settings', as: 'settings'
  patch 'change_email', to: 'settings#change_email'
  get 'friends', to: 'friends#index', as: 'friends'

  patch 'update_profile_image', to: 'settings#update_profile_image'
  patch 'update_name', to: 'settings#update_name'
  post 'add_billing_method', to: 'settings#add_billing_method'

  patch 'edit_billing_method/:id', to: 'settings#edit_billing_method', as: 'edit_billing_method'
  delete 'delete_billing_method/:id', to: 'settings#delete_billing_method', as: 'delete_billing_method'






  # Games routes
  resources :games, only: [:create, :show] do
    member do
      post 'start'  # This creates start_game_path(@game)
      post 'chat'            # For the chat feature
      post 'leave' #Deletes the current user from the game
    end

    collection do
      post 'join'  # Handles POST /games/join
    end
  end


  resources :billing_methods, only: [] do
    member do
      patch :update
      delete :destroy
    end
  end


  resources :games do
    post 'invite_friends', on: :member
  end

  resources :settings, only: [] do
    collection do
      patch :change_email
      patch :update_profile_image
      patch :update_name
      post :add_billing_method
    end
    member do
      patch :edit_billing_method
      delete :delete_billing_method
    end
  end

  get '/store_items', to: 'store_items#index', as: 'store_items'
  post '/store_items/purchase', to: 'store_items#purchase'

  resources :users
  resources :sessions, only: [ :new, :create, :destroy ]

  match "/signup", to: "users#new", via: :get, as: "signup"

  # match "/login", to: "sessions#new", via: :get, as: "login"
  match "/logout", to: "sessions#destroy", via: :delete, as: "logout"

  root "landing#index"

  resources :store_items do
    collection do
      post 'purchase'
    end
  end

  resources :friends, only: [:index, :create] do
    member do
      post 'accept', to: 'friends#accept'
      delete 'reject', to: 'friends#reject'
      delete 'cancel', to: 'friends#cancel'
      delete 'unfriend', to: 'friends#unfriend'
    end

  end

  resources :password_resets, only: [:new, :create, :edit, :update]
end
