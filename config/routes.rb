Rails.application.routes.draw do
  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get 'static_pages/*page', to: 'static_pages#show'

  root 'static_pages#show', page: 'home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :users, only: :show

  get '/fav_genres', to: 'favorite_genres#index'
  post '/fav_genres', to: 'favorite_genres#create'

  get '/rate_books', to: 'reviews#index'
  post '/rate_books', to: 'reviews#create'

  get '/genres/', to: 'genres#index'
  get '/genres/:id', to: 'genres#show', as: 'genre'

  get '/books', to: 'books#index'
  get '/books/:id', to: 'books#show', as: 'book'

  get '/books/:book_id/reviews/new', as: 'new_text_review', to: 'text_reviews#new'
  post '/books/:book_id/reviews', as: 'text_reviews', to: 'text_reviews#create'

  get '/recommendations', to: 'recommendations#index'
end
