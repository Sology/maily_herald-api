module MailyHerald
  module Api
    module V1
      class DispatchesController < ResourcesController
        def destroy
          @item.archive!
          render_api @item, root: root
        end
      end
    end
  end
end
