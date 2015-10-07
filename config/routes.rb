Study::Application.routes.draw do
  
  captcha_route

  mount Ckeditor::Engine => '/ckeditor'
  
  resources :cart do
    get :add, :on => :collection
    get :confirm, :on => :collection
    get :list, :on => :collection
  end
  
  resources :orders do
    get :pay, :on => :member
    get :success, :on => :member
  end
  
  resources :card_nos do
    get :select, :on => :collection
  end
  
  resources :products do
    post :praise, :on => :member
    get :search, :on => :collection
  end
  resources :classworks, :only => [:index, :show, :edit, :update]
  resources :balances, :teachers, :user_accounts
  
  namespace :admin do
    root :to => "home#index"
    resources :classworks
    resources :user_classworks, :except => [:create]
    resources :products
    resources :notes, :only => [:index, :show, :destroy]
    resources :users, :only => [:index, :show]
    resources :knowledge_trees, :except => [:destroy]
    resources :product_trees, :except => [:destroy] do
      get :destroy_global_asset, :on => :collection
    end
    resources :global_assets
    resources :product_tree_groups do
      post :drag_drop, :on => :member
    end
    resources :teachers
    resources :orders do
      post :open, :on => :member
      get :export, :on => :collection
    end
    resources :user_accounts
    resources :cards do
      resources :card_nos do
        get :export, :on => :collection
      end
    end
    resources :used_card_nos
    resources :user_money_records
    resources :system_messages
    match '/knowledge_trees/destroy/:id(.:format)', :to => "knowledge_trees#destroy", :via => :POST
    match '/product_trees/destroy/:id(.:format)', :to => "product_trees#destroy", :via => :POST
  end


  # omniauth
  match '/auth/:provider/callback', :to => 'user_sessions#create'
  match '/auth/failure', :to => 'user_sessions#failure'

    # Custom logout
  match '/logout', :to => 'user_sessions#destroy'
  match '/users/check_key(.:format)', :to => 'user_sessions#check_key', :via => :POST

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
  root :to => 'home#index'
  match 'accounts/:id' => 'home#accounts_show', :as => :accounts_show
  match 'accounts' => 'home#accounts_index', :as => :accounts_index
  match 'accounts/assets/:account_id' => 'home#accounts_assets', :as => :accounts_assets
  match 'accounts/assets/down/:account_id/:asset_id' => 'home#accounts_assets_down', :as => :accounts_assets_down
  match 'profile' => 'home#user_profile', :as => :user_profile
  match 'update_profile' => 'home#update_user_profile', :as => :update_user_profile, :via => :post
  match 'password' => 'home#user_password', :as => :user_password
  match 'update_password' => 'home#update_user_password', :as => :update_user_password, :via => :post
  match 'knowledge/index' => 'home#knowledge_index', :as => :knowledge_index
  match 'knowledge/listen' => 'home#knowledge_listen', :as => :knowledge_listen
  match 'update_note' => 'home#update_note', :as => :update_user_note, :via => :post
  match 'notes' => 'home#notes_index', :as => :user_notes
  match 'notes/:account_id' => 'home#notes_show', :as => :user_notes_show
  match 'notes/destroy/:id' => 'home#notes_destroy', :as => :user_notes_destroy, :via => :delete
  match 'notes/down/:id' => 'home#notes_down', :as => :user_notes_down
  match 'notes/account/:account_id' => 'home#account_notes_down', :as => :user_account_notes_down
  match 'money_records' => 'home#money_records', :as => :user_money_records
  match 'recharges/index' => 'home#recharges_index', :as => :user_recharges_index
  match 'recharges/pay/:id' => 'home#recharges_pay', :as => :user_recharges_pay
  match 'recharges' => 'home#recharges_create', :as => :user_recharges_create, :via => :post
  match 'messages/system' => 'home#messages_system', :as => :user_messages_system
  match 'messages/study' => 'home#messages_study', :as => :user_messages_study
  match 'messages/count' => 'home#messages_count', :as => :user_messages_count
  match 'messages/private' => 'home#messages_private', :as => :user_messages_private
  match 'messages/private/destroy/:id' => 'home#messages_private_destroy', :as => :user_messages_private_destroy, :via => :delete
  match 'messages/private/show' => 'home#messages_private_show', :as => :user_messages_private_show
  match 'messages/private/create' => 'home#messages_private_create', :as => :user_messages_private_create
  match 'learn_schedule/update' => 'home#learn_schedule_update', :as => :learn_schedule_update, :via => :post
  match 'questions' => 'home#questions', :as => :questions
  match 'help' => 'home#help', :as => :help
  match 'app' => 'home#app', :as => :app

  # See how all your routes lay out with "rake routes"
  match ':module/:year/:month/:day/:config/:imagename' => 'images#clips', :constraints => { :module => /(teacher|product|user)/, :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :config => /\w{1,20}/, :imagename => /.*{1,50}.(gif|jpg|png)/}
  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
