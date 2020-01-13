Rails.application.routes.draw do
  get 'password_resets/new'

  get 'password_resets/edit'

  root 'static_pages#home'

  get 'legal' => 'static_pages#legal'
  get 'instructions' => 'static_pages#install_instructions'
  get 'signup'  => 'users#new'

  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'

  get 'admin' => 'static_pages#admin_overview'

  get 'accessible_apps' => 'accessible_apps#index'

  get '/auth/bamboo/callback', to: 'users#link_bamboo_account'
  delete '/auth/bamboo', to: 'users#unlink_bamboo_account'
  get 'bamboo_plans' => 'apps#users_bamboo_plans'
  get 'bamboo_builds' => 'releases#bamboo_builds'

  namespace :mobile do
    resources :apps,              only: [:show] do
      resources :releases,        only: [:show]
    end
  end

  resources :users,               only: [:edit, :update] do
    get 'send_activation' => 'users#send_activation'
  end

  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]

  get '/apps/find_release' => 'apps#find_release'

  resources :apps do
    resources :groups,            only: [:new, :edit, :update, :create, :destroy] do
      resources :group_users,     only: [:create, :destroy]
    end
    resources :admins,            only: [:create, :destroy]
    get 'releases/new_prototype' => 'releases#new_prototype'
    get 'releases/new_beta' => 'releases#new_beta'
    get 'releases/available' => 'releases#available'
    post 'remove_release_from_group' => "apps#remove_release_from_group"
    resources :containers, only: [:new, :create, :show] do
      get 'status' => 'containers#status'
      get 'download' => 'containers#download'
    end
    resources :releases,           only: [:create, :destroy, :show] do
      resources :builds,          only: [:create] do
        get 'manifest' => 'builds#manifest'
      end
      resources :feedbacks,       only: [:create, :new, :index, :destroy] do
        post 'toggle' => "feedbacks#toggle"
      end
      resources :downloads,       only: [:index, :destroy, :create]
      get 'container' => 'releases#container'
      get 'web_container' => 'releases#web_container'
      get 'status' => 'releases#status'
      get 'icon' => 'releases#icon'
      get 'report' => 'releases#report'
      get 'release_notes' => 'releases#release_notes'
      post 'release_to_group' => "releases#release_to_group"
      post 'share_app' => "releases#share_app"
    end
  end

  match '*path', via: :all, to: 'static_pages#error_404'

end
