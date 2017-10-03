Rails.application.routes.draw do
  get 'static_pages/*page', to: 'static_pages#show'

  root 'static_pages#show', page: 'home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
