Rails.application.routes.draw do

  post 'todos/search'
  post 'todos/active_status'
  post 'todos/rearrange'

  devise_for :users

  resources :users do
    resources :todos
  end

  resources :todos



  root "todos#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
