# For details on the DSL available within this file, see
# http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do

  ######################## Public website routes ############################

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post],
        as: 'auth' # used by omniauth
  resources :collections, only: :index
  resources :elements, only: :index, param: :name
  match '/health', to: 'health#index', via: :get
  resources :items, only: [:index, :show] do
    match '/image', to: 'items#image', via: :get
  end
  match '/search', to: 'search#index', via: :get
  match '/signin', to: 'sessions#new', via: :get
  match '/signout', to: 'sessions#destroy', via: :delete

  ############################ REST API routes ##############################

  namespace :api do
    match '/', to: redirect('/api/v1', status: 303), via: :all
    namespace :v1 do
      root 'landing#index'
      resources :elements, only: :index
      resources :harvests, only: [:create, :destroy, :update], param: :key
      resources :items, only: :update
    end
  end

  ##################### Shibboleth-protected routes #########################

  namespace :admin do
    root 'dashboard#index'
    resources :boosts
    match '/configuration', to: 'configuration#index', via: :get
    match '/configuration', to: 'configuration#update', via: :patch
    resources :content_services, param: :key, path: 'content-services' do
      resources :element_mappings, path: 'element-mappings'
      match '/clear-element-mappings', to: 'content_services#clear_element_mappings',
            via: :delete, as: 'clear_element_mappings'
      match '/harvest', to: 'content_services#harvest', via: :post, as: 'harvest'
      match '/purge', to: 'content_services#purge', via: :post, as: 'purge'
    end
    resources :element_defs, path: 'elements', param: :name do
      resources :value_mappings, path: 'value-mappings'
      match '/usages', to: 'element_defs#usages', via: :get, as: 'usages'
    end
    match '/elements/import', to: 'element_defs#import', via: :post, as: 'element_defs_import'
    resources :harvests, param: :key, only: [:destroy, :index, :show] do
      match '/abort', to: 'harvests#abort', via: :patch, as: 'abort'
    end
    resources :items, only: :show do
      match '/purge-cached-images', to: 'items#purge_cached_item_images', via: :patch
    end
    resources :users, param: :username do
      match '/reset-api-key', to: 'users#reset_api_key', via: :post, as: 'reset_api_key'
    end
  end

  ############################## Root route ##################################

  match '/', to: redirect(Configuration.instance.dls_url, status: 303),
        via: :all, as: 'root'

  # catch unknown routes
  match '*path', to: 'errors#not_found', via: :all

end
