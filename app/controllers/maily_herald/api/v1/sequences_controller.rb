module MailyHerald
  module Api
    module V1
      class SequencesController < DispatchesController

        private

        def item_params
          params.require(:sequence).permit(:title, :list, :start_at)
        end
      end
    end
  end
end
