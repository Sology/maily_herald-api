MailyHerald::Engine.routes.draw do

  namespace :api, defaults: {format: "json"} do
    namespace :v1 do
      resources :lists, except: [:new, :edit] do
        member do
          post "subscribe/:entity_id"   => :subscribe
          post "unsubscribe/:entity_id" => :unsubscribe
        end

        resources :subscriptions, only: :index, controller: 'lists/subscriptions'
      end

      resources :contexts, only: :index do
        collection do
          get ":context_name" => :show
        end
      end

      %w(sequences ad_hoc_mailings one_time_mailings periodical_mailings).each do |r|
        res = r.to_sym
        resources res, except: [:new, :edit] do
          if res == :sequences
            resources :sequence_mailings, as: :mailings, path: "mailings", except: [:new, :edit] do
              member do
                get  "preview/:entity_id" => :preview
              end
            end
          else
            member do
              get  "preview/:entity_id" => :preview

              if res == :ad_hoc_mailings
                post :deliver
                post "deliver/:entity_id" => :deliver
              end
            end
          end
        end
      end
    end
  end

end

