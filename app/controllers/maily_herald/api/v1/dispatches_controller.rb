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

        private

        def load_entity
          @entity = @item.list.context.scope.find(params[:entity_id])
        end

        def set_resource
          "MailyHerald::#{dispatch_class_name}".constantize
        end

        def item_params
          params.require(mark_required).permit(:title, :mailer_name, :list, :from, :conditions, :subject, :template)
        end

        def root
          root = dispatch_class_name.camelize(:lower)
          @items ? root.pluralize : root
        end

        def dispatch_class_name
          controller_name.classify
        end
      end
    end
  end
end
