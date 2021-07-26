Rails.application.routes.draw do
  get '/check.txt', to: proc {[200, {}, ['simple_check']]}

  root 'home#index'
  get 'stats' => 'home#stats'
  get 'search/people' => 'home#search_people', as: 'search_people'
  get 'search/buildings' => 'home#search_buildings', as: 'search_buildings'
  get 'searches/saved/:what' => 'home#saved_searches'

  # get '/about' => 'home#about', as: 'about'
  get '/photos/:id/:style/:device' => 'buildings/main#photo', as: 'photo'

  get '/forge' => 'forge#index', as: 'forge'

  devise_for :users,
             path: 'u',
             skip: [ :registerable, :confirmable ],
             controllers: { sessions: "sessions" } #, omniauth_callbacks: "omniauth_callbacks" }

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  concern :people_directory do
    collection do
      get :advanced_search_filters
      get :building_autocomplete
      get :autocomplete
      post :bulk_review
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
    end
    resources :photographs
    resources :merges, only: %i[new create], controller: 'buildings/merges'
  end

  CensusYears.each do |year|
    resources :bulk, controller: 'census_records/bulk_updates', path: "census/#{year}/bulk", as: "census_#{year}_bulk"
  end

  resources :census_1900_records,
            concerns: [:people_directory],
            controller: 'census_records/nineteen_aught',
            path: 'census/1900',
            as: 'census1900_records'

  resources :census_1910_records,
            concerns: [:people_directory],
            controller: 'census_records/nineteen_ten',
            path: 'census/1910',
            as: 'census1910_records'

  resources :census_1920_records,
            concerns: [:people_directory],
            controller: 'census_records/nineteen_twenty',
            path: 'census/1920',
            as: 'census1920_records'

  resources :census_1930_records,
            concerns: [:people_directory],
            controller: 'census_records/nineteen_thirty',
            path: 'census/1930',
            as: 'census1930_records'

  resources :census_1940_records,
            concerns: [:people_directory],
            controller: 'census_records/nineteen_forty',
            path: 'census/1940',
            as: 'census1940_records'

  resources :contacts, only: %i[new create]
  get '/contact' => 'contacts#new'

  concern :moveable do
    member do
      put :move_up
      put :move_down
      put :move_to_top
      put :move_to_bottom
    end
  end

  resources :document_categories, concerns: %i[moveable] do
    resources :documents, concerns: %i[moveable]
  end

  resources :documents, concerns: %i[moveable]

  resources :flags

  resources :localities

  resources :map_overlays

  resources :people, controller: 'people/main' do
    collection do
      get :advanced_search_filters
      get :autocomplete
    end
    resources :merges, only: %i[new create], controller: 'people/merges'
    resources :photographs
  end

  resources :photographs do
    patch :review, on: :member
  end

  resources :settings, only: %i[index create]

  resources :street_conversions

  resources :users do
    member do
      put 'enable'
      put 'disable'
      put 'disable_and_reset'
      get 'mask'
      put :resend_invitation
    end
    resource :user_account
    resources :roles
  end

  resources :vocabularies, only: :index do
    resources :terms do
      get 'peeps/:year' => 'terms#peeps'
      get 'peeps/:year/:page' => 'terms#peeps'
      post :import, on: :collection
    end
  end

  get 'uploads/pictures/:id/:style/:device' => 'cms/pictures#show', as: 'picture'

  match '*path'   => 'cms/pages#show', via: :all, constraints: -> (request) { request.format.html? && request.path != '/routes' }
end
