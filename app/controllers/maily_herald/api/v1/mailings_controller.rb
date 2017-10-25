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
      end
    end
  end
end
