Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: { sessions: 'overrides/sessions' }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  scope :api do
    get 'users/members'
    resources :users, :only => [:index, :show, :edit, :create, :update]
  end
end
