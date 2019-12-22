Rails.application.routes.draw do
  get 'users/index'
  resources :duties
  resources :messages
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
