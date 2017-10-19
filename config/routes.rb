MailyHerald::Engine.routes.draw do

  namespace :api, defaults: {format: "json"} do
    namespace :v1 do
      resources :lists, only: [:show, :create, :update]
    end
  end

end

