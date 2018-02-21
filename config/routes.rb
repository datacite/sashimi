Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :heartbeat, only: [:index]
  resources :index, path: '/', only: [:index]
  resources :status, only: [:index]
end
