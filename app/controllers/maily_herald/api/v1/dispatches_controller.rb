module MailyHerald
  module Api
    module V1
      class DispatchesController < ResourcesController
        def index
          super do |items|
            case params[:state]
            when "enabled"
              items.enabled
            when "disabled"
              items.disabled
            when "archived"
              items.archived
            when "not_archived"
              items.not_archived
            else
              items
            end
          end
        end

        def destroy
          @item.archive!
          render_api @item, root: root
        end
      end
    end
  end
end
