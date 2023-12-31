Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
 root :to =>"homes#top"
 get "home/about"=>"homes#about"

 resources :books
 resources :users
 get 'tagsearches/search' => "tagsearches#search"
 get '/search', to: 'searches#search'
 get 'messages/:id' => 'messages#message', as: 'message'
 post 'messages' => 'messages#create', as: 'messages'


 resources :books do
  resources :book_comments, only: [:create, :destroy]
  resource :favorites, only: [:create, :destroy]
end
  resources :users do
    resource :relationships, only: [:create, :destroy]
  	get "followings" => "relationships#followings", as: "followings"
  	get "followers" => "relationships#followers", as: "followers"
 end
end
