Rails.application.routes.draw do
  root to: 'duties#index'
  get 'users/index'
  resources :duties
  resources :messages
  resources :users
  resources :answers
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
