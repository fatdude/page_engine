Rails.application.routes.draw do    
  resources :pages, :only => [:index, :show]

  namespace :admin do
    resources :page_parts
    resources :page_snippets, :except => :show
    resources :pages do
      collection do
        put :sort
      end

      member do
        post :duplicate
      end
      resources :pages
      resources :page_parts
    end
  end
  match ":permalink", :to => "pages#show"
end
