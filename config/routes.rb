Rails.application.routes.draw do
  get 'static_pages/*page', to: 'static_pages#show'

  root 'static_pages#show', page: 'home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/sign_up', to: 'users#new'
  resources :users, except: :new

  get '/sign_in', to: 'sessions#new'
  post '/sign_in', to: 'sessions#create'
  delete '/sign_out', to: 'sessions#destroy'

  get '/fav_genres', to: 'favorite_genres#index'
  post '/fav_genres', to: 'favorite_genres#create'

  get '/rate_books', to: 'reviews#index'
  post '/rate_books', to: 'reviews#create'

  get '/genres/', to: 'genres#index'
  get '/genres/:id', to: 'genres#show', as: 'genre'

  get '/books/:id', to: 'books#show', as: 'book'

  get '/recommendations', to: 'recommendations#index'
end
