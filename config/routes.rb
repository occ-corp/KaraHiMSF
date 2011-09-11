# -*- coding: utf-8 -*-

KaraHiMsf::Application.routes.draw do
  resources :interviews, :only => [:index, :create, :update]

  resources :answers, :only => [:create, :update]

  resources :questions

  resource :adjustment, :only => [:show, :update]

  resources :incompletes, :only => [:index, :show]

  match 'evaluation_trees' => 'evaluation_trees#index', :via => :put
  match 'evaluation_trees/csv_import' => 'evaluation_trees#csv_import', :via => :get
  match 'evaluation_trees/confirm' => 'evaluation_trees#confirm', :via => :put

  resources :evaluation_trees

  resources :systems, :only => [:index, :edit, :update]

  resources :items

  resources :evaluation_items

  resources :item_belongs

  match "item_groups/new/:id" => "item_groups#new", :via => :get
  resources :item_groups

  resources :evaluation_orders

  resources :evaluation_multifaceteds, :controller => :evaluations

  resources :evaluation_top_downs, :controller => :evaluations

  resources :evaluations

  resources :points

  resources :evaluation_category_multifaceted

  resources :evaluation_category_top_down

  resources :evaluation_categories

  # resources :scores
  # match 'scores/update' => 'scores#update', :via => :get

  resources :roles

  resources :qualifications

  resources :job_titles

  resources :divisions

  resources :belongs
  match 'belongs/update' => 'belongs#update'

  resources :settings

  # map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  match 'logout' => 'sessions#destroy'

  # map.login '/login', :controller => 'sessions', :action => 'new'
  match 'login' => 'sessions#new'

  # map.register '/register', :controller => 'users', :action => 'create'
  match 'register' => 'users#create'

  # map.signup '/signup', :controller => 'users', :action => 'new'
  match 'signup' => 'users#new'

  # map.connect 'users/incompletes', :controller => 'users', :action => 'incompletes'
  match 'users/incompletes' => 'users#incompletes', :via => :get

  # map.connect 'users/result', :controller => 'users', :action => 'result'
  match 'users/result' => 'users#result', :via => :get
  match 'users/results' => 'users#results', :via => :get

  resources :users do
    resources :scores
    match 'result' => 'users#result', :via => :get
  end

  match 'users/update' => 'users#update', :via => :put

  resource :session

  root :to => 'scores#index', :via => :get

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
