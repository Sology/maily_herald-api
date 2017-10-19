MailyHerald::Engine.routes.draw do

  namespace :api, defaults: {format: "json"} do
    namespace :v1 do
      resources :lists, except: [:new, :edit, :destroy] do
        member do
          post "subscribe/:entity_id" => :subscribe
          post "unsubscribe/:entity_id" => :unsubscribe
        end
      end

      resources :contexts, only: [] do
        collection do
          get ":context_name" => :show
        end
      end
    end
  end

end

