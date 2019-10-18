Rails.application.routes.draw do
  post 'todos/rearrange'

  devise_for :users

  resources :shares

  resources :todos do
    resources :comments
  end



  root "todos#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
