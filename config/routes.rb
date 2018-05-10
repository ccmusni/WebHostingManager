Rails.application.routes.draw do
  root 'login#index'
  get 'login' => 'login#index'
  post 'login/authenticate'
  get 'login/test'

  get 'logout' => 'logout#index'

  post 'server_accounts/test_connection'
  post 'server_accounts/update_connection'
  post 'server_accounts/enable_ess'
  resources :server_accounts
  
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
