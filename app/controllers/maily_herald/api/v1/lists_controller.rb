module MailyHerald
  module Api
    module V1
      class ListsController < ResourcesController
        before_action :load_entity, only: [:subscribe, :unsubscribe]

        def subscribe
          @subscription = @item.subscribe! @entity
          render_subscription
        end

        def unsubscribe
          @subscription = @item.unsubscribe! @entity
          render_subscription
        end

        %w(subscribers opt_outs potential_subscribers).each do |name|
          define_method(name) do
            entities = @item.send(name)
            outcome = []
            entities.each {|e| outcome << build_serialized_entity(e)} if entities.any?
            render_api({name.camelize(:lower) => outcome})
          end
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
          @items ? "lists": "list"
        end

        def render_subscription
          render_api @subscription, root: 'subscription'
        end

        def build_serialized_entity entity
          {
            id: entity.id,
            email: entity.try(:email)
          }
        end
      end
    end
  end
end
