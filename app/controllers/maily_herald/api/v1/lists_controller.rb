module MailyHerald
  module Api
    module V1
      class ListsController < ResourcesController

        def subscribe
          @entity = @item.context.model.find params[:entity_id]
          @item.subscribe! @entity
          render_api({})
        end

        private

        def set_resource
          MailyHerald::List
        end

        def item_params
          params.require(root).permit(:title, :context_name)
        end

        def root
          "list"
        end
      end
    end
  end
end
