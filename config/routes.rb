Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'landing#index'

  ######################## Public website routes ############################

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post],
        as: 'auth' # used by omniauth
  match '/signin', to: 'sessions#new', via: :get
  match '/signout', to: 'sessions#destroy', via: :delete

  resources :content_services, param: :key, path: 'services', only: [:index, :show]

  ############################ REST API routes ##############################

  namespace :api do
    root 'landing#index'
  end

  ##################### Shibboleth-protected routes #########################

  namespace :admin do
    root 'dashboard#index'
    resources :content_services, param: :key, path: 'content-services'
    resources :users, param: :username do
      match '/reset-api-key', to: 'users#reset_api_key', via: :post, as: 'reset_api_key'
    end
  end

end
