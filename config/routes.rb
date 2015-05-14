require 'sidekiq/web'

Rails.application.routes.draw do

  get "static_pages/home"
  get "static_pages/help"

  get '/signout', to: 'sessions#destroy'

  get '/auth/:provider/callback' => 'users#login'
  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root to: 'static_pages#home'

  resources :interests, only: [:create, :destroy, :update]
  resources :my_locations, only: [:create, :destroy, :update],controller: 'locations'
  resources :my_badges, only: [:create, :destroy, :update, :like],controller: 'badges'
  resources :pictures do
    collection do
      get :new_upload_form, :new_upload_post_form, :pics_edit, :set_default_pic, :set_visible_pic, :import_fb_pictures
    end
  end


  resources :my_badges do
    member do
      get :like, controller: 'badges'
    end
    collection do
      get :badge_list, controller: 'badges'
    end
  end


  resources :users do
    collection do
      get :friends, :page_friends, :autocomplete_location_address, :page_search_criteria, :like_list, :page_like_list, :new_people_around, :page_new_people_around,:crush_list, :date_list, :page_date_list
    end
    member do
      patch :add_location, :badges, :add_testimonial, :add_picture, :map_delete
      get :search_criteria, :likes, :pics_edit, :set_default_pic, :set_visible_pic, :likes_testimonial, :delete_testimonial, :timeline, :crush, :set_godate, :godate
      post :update_status, :update_about_me
    end
  end

  resources :conversations , only: [:show] do
    resources :messages, only: [:create]
  end
  
  resources :posts do
    collection do
      get :next_page
    end
     member do
      get :badges
    end
    resources :comments, shallow: true
  end
  
   resources :comments do
    member do
      get :more
    end
  end

  mount Sidekiq::Web, at: '/sidekiq'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
