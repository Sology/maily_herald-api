module MailyHerald
  module Api
    module V1
      class ListsController < ResourcesController
        before_action :load_entity, only: [:subscribe, :unsubscribe]

        def subscribe
          @item.subscribe! @entity
          render_api({})
        end

        def unsubscribe
          @item.unsubscribe! @entity
          render_api({})
        end

        private

        def load_entity
          @entity = @item.context.model.find params[:entity_id]
        end

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
