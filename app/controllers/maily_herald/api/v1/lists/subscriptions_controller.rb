module MailyHerald
  module Api
    module V1
      module Lists
        class SubscriptionsController < BaseController
          before_action :load_list
          before_action :load_subscriptions

          def index
            render_api @subscriptions, paginate: true, root: "subscriptions"
          end

          private

          def load_list
            @list = MailyHerald::List.find params[:list_id]
          end

          def load_subscriptions
            @subscriptions = case params[:kind]
                             when "active"
                               @list.subscriptions.active
                             else
                               @list.subscriptions
                             end
          end
        end
      end
    end
  end
end
