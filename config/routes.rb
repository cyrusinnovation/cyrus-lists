Listlist::Application.routes.draw do
  resources :lists, :except => [:show, :update] do
    resources :archives, :only => [:index]
    resources :subscribers, :only => [:index]
    get 'poll_for_changes/' => "archives#poll_for_changes"
  end

  delete '/users/destroy' => "users#destroy", :as => "remove_user"

  get "remove_user_selector" => "users#remove_user_selector"

  get "add_current_user_to_list" => "lists#add_current_user"
  get "remove_current_user_from_list" => "lists#remove_current_user"

  post "incoming" => "incoming_mail#create"

  post "change_description" => "lists#change_description"
  post "change_category" => "lists#change_category"
  post "add_subscribers_to_list" => "lists#add_subscribers"
  post "remove_from_list" => "lists#remove_subscriber"
  get "reorder_categories" => "categories#reorder_categories"


  root :to => "lists#index"
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  mount Resque::Server.new, :at => '/resque'
end
