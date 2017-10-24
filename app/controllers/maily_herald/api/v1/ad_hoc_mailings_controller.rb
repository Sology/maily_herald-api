module MailyHerald
  module Api
    module V1
      class AdHocMailingsController < MailingsController
        before_action :load_entity, only: :deliver, if: :entity_id_present?

        def deliver
          if entity_id_present?
            @item.schedule_delivery_to @entity
          else
            @item.schedule_delivery_to_all
          end

          render_api({})
        end

        private

        def mark_required
          "ad_hoc_mailing"
        end

        def entity_id_present?
          params[:entity_id].present?
        end
      end
    end
  end
end
