MailyHerald::Engine.routes.draw do

  namespace :api, defaults: {format: "json"} do
    namespace :v1 do
      resources :lists, only: [:show, :create, :update] do
        member do
          post "subscribe/:entity_id" => :subscribe
        end
      end
    end
  end

end

