Rails.application.routes.draw do
  root 'users#home'

  mount_devise_token_auth_for 'User', at: 'auth', controllers: { sessions: 'overrides/sessions' }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  scope :api do
    get 'users/members'
    get 'users/matchmakers'
    get 'users/viewable'
    get 'users/:id/get', to: 'users#get'
    get 'users/:id/partner_matches', to: 'users#partner_matches'
    get 'users/my_partner_matches'
    post 'users/:id/send_invitation', to: 'users#send_invitation'
    post 'users/invite', to: 'users#invite'
    post 'users/accept', to: 'users#accept'
    resources :users, :only => [:index, :show, :edit, :create, :update]

    post 'user_friends/request_sharing', to: 'user_friends#request_sharing'
    post 'user_friends/:id/accept_request', to: 'user_friends#accept_request'
    get 'user_friends/waiting_friends'

    get 'requirements/get_by_user_id'
    resources :requirements, :only => [:create, :update]

    post 'questions/save_answers', to: 'questions#save_answers'
    resources :questions, :only => [:index, :create, :update]

    post 'eval_partners/permit'

    post 'rooms/:id/join', to: 'rooms#join'
    post 'rooms/:id/left', to: 'rooms#left'
    resources :rooms, :only => [:index, :show, :create, :edit, :update]
  end
end
