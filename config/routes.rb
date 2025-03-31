# frozen_string_literal: true

Rails.application.routes.draw do
  get '/check.txt', to: proc {[200, {}, ['simple_check']]}

  if Rails.env.development?
    redirector = lambda { |params, _req|
      ApplicationController.helpers.asset_path(params[:name].split('-').first + '.map')
    }
    constraint = ->(request) { request.path.ends_with?('.map') }
    get 'assets/*name', to: redirect(redirector), constraints: constraint
  end

  concern :moveable do
    member do
      put :move_up
      put :move_down
      put :move_to_top
      put :move_to_bottom
    end
  end

  concern :reviewable do
    put :review, on: :member
  end

  root 'home#index'
  get 'stats' => 'home#stats'
  get 'api/search', action: :search, controller: 'api/search'
  get 'api/json', action: :json, controller: 'api/json'
  get 'search/people' => 'home#search_people', as: 'search_people'
  get 'search/buildings' => 'home#search_buildings', as: 'search_buildings'
  get 'searches/saved/:what' => 'home#saved_searches'

  get '/photos/:id/:style/:device' => 'buildings/main#photo', as: 'photo'

  get '/forge' => 'forge#index', as: 'forge'
  get '/:locality_slug/forge' => 'forge#index', as: 'local_forge'

  post '/census/rebuild', to: 'census_records/main#rebuild', as: 'rebuild_index'

  devise_for :users,
             path: 'u',
             controllers: { registrations: 'users/registrations',
                            sessions: 'users/sessions',
                            omniauth_callbacks: 'users/omniauth_callbacks' }

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  concern :census_directory do
    collection do
      get :demographics
      get :advanced_search_filters
      get :building_autocomplete
      get :autocomplete
      post :bulk_review
      post :bulk_person_match
    end
    member do
      put :save_as
      put :reviewed
      put :make_person
    end
  end

  namespace :cms do
    resources :pages
  end

  resources :buildings, controller: 'buildings/main' do
    collection do
      get :autocomplete
      get :advanced_search_filters
      post :bulk_review
    end
    member do
      put :review
      get :address
    end
    with_options(concerns: %i[reviewable]) do
      resources :narratives
      resources :photographs
      resources :audios
      resources :videos
      resources :documents
    end
    resources :merges, only: %i[new create], controller: 'buildings/merges'
  end

  resources :bulk, controller: 'census_records/bulk_updates', path: 'census/:year/bulk', as: 'census_bulk'
  resources :census_records,
            controller: 'census_records/main',
            path: 'census/:year',
            concerns: :census_directory

  CensusYears.each do |year|
    resources :bulk, controller: 'census_records/bulk_updates', path: "census/#{year}/bulk", as: "census_#{year}_bulk"
    resources :"census_#{year}_records",
              concerns: [:census_directory],
              controller: 'census_records/main',
              path: "census/#{year}",
              as: "census#{year}_records",
              defaults: { year: year }
  end

  resources :contacts, only: %i[new create]
  get '/contact' => 'contacts#new'

  resources :document_categories, concerns: %i[moveable] do
    resources :documents, concerns: %i[moveable]
  end

  resources :documents, concerns: %i[moveable]

  resources :flags

  resources :localities, concerns: %i[moveable] do
    put :set, on: :member
    put :reset, on: :collection
  end

  resources :map_overlays

  resources :people, controller: 'people/main' do
    collection do
      get :advanced_search_filters
      get :autocomplete
    end
    resources :merges, only: %i[new create], controller: 'people/merges'
    with_options(concerns: %i[reviewable]) do
      resources :narratives
      resources :photographs
      resources :audios
      resources :videos
      resources :documents
    end
  end

  with_options(concerns: %i[reviewable]) do
    resources :narratives
    resources :photographs
    resources :audios
    resources :videos
  end

  resources :settings, only: %i[index create]

  resources :street_conversions

  resources :users do
    member do
      put 'enable'
      put 'disable'
      put 'disable_and_reset'
      put 'mask'
      put :resend_invitation
    end
    resource :user_account
    resources :roles
  end

  resources :user_groups

  resources :vocabularies, only: :index do
    resources :terms do
      get 'peeps/:year' => 'terms#peeps'
      get 'peeps/:year/:page' => 'terms#peeps'
      post :import, on: :collection
    end
  end

  get 'uploads/pictures/:id/:style/:device' => 'cms/pictures#show', as: 'picture'

  match '*path' => 'cms/pages#show', via: :all, constraints: -> (request) { request.format.html? && request.path != '/routes' }
end
