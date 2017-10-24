module MailyHerald
  module Api
    module V1
      class MailingsController < DispatchesController
        before_action :load_entity, only: :preview

        def preview
          @entity = @item.list.context.scope.find(params[:entity_id])
          mail = @item.build_mail @entity

          render_api({mailPreview: Mail::MessageSerializer.new(mail).as_json})
        end

        private

        def load_entity
          @entity = @item.list.context.scope.find(params[:entity_id])
        end

        def set_resource
          "MailyHerald::#{mailing_class_name}".constantize
        end

        def item_params
          params.require(mark_required).permit(:title, :mailer_name, :list, :from, :conditions, :subject, :template)
        end

        def root
          root = mailing_class_name.camelize(:lower)
          @items ? root.pluralize : root
        end

        def mailing_class_name
          controller_name.classify
        end
      end
    end
  end
end
