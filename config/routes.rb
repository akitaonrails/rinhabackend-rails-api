Rails.application.routes.draw do
  resources :pessoas
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  #root 'pessoas#index'

  get 'contagem-pessoas', to: 'pessoas#contagem'
end
