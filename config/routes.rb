Rails.application.routes.draw do
  get 'bitbucket_commits/index'
  get 'bitbucket_commits/user_commits'
  root to: "duties#index"
  get "users/index"
  resources :duties
  resources :messages
  resources :users
  resources :answers
  resources :actions
  resources :bitbucket_commits
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
