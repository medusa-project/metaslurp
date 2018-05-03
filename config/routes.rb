# For details on the DSL available within this file, see
# http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do

  root 'landing#index'

  ######################## Public website routes ############################

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post],
        as: 'auth' # used by omniauth
  match '/signin', to: 'sessions#new', via: :get
  match '/signout', to: 'sessions#destroy', via: :delete

  resources :collections, only: :index
  resources :content_services, param: :key, path: 'services', only: [:index, :show]
  resources :favorites, only: :index
  resources :items, only: :index
  match '/search', to: 'search#index', via: :get

  ############################ REST API routes ##############################

  namespace :api do
    match '/', to: redirect('/api/v1', status: 303), via: :all
    namespace :v1 do
      root 'landing#index'
      resources :elements, only: :index
      resources :items, only: :update
    end
  end

  ##################### Shibboleth-protected routes #########################

  namespace :admin do
    root 'dashboard#index'
    match '/configuration', to: 'configuration#index', via: :get
    match '/configuration', to: 'configuration#update', via: :patch
    resources :content_services, param: :key, path: 'content-services' do
      match '/element-mappings', to: 'content_services#clear_element_mappings',
            via: :delete, as: 'element_mappings'
      match '/purge', to: 'content_services#purge', via: :post, as: 'purge'
      match '/reindex', to: 'content_services#reindex', via: :post, as: 'reindex'
    end
    resources :element_defs, path: 'elements', param: :name, except: :show
    match '/elements/import', to: 'elements#import', via: :post, as: 'element_defs_import'
    resources :items, only: :show
    resources :roles, param: :key
    resources :users, param: :username do
      match '/reset-api-key', to: 'users#reset_api_key', via: :post, as: 'reset_api_key'
    end
  end

end
