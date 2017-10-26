module MailyHerald
  module Api
    module V1
      class LogsController < ResourcesController
        before_action :load_mailing,  only: :index,   if: :mailing_id_present?
        before_action :load_entity,   only: :index,   if: :entity_id_and_type_present?

        def index
          super do |items|
            items = items.for_mailing(@mailing) if  mailing_id_present?
            items = items.for_entity(@entity)   if  entity_id_and_type_present?

            items = case params[:status]
                    when "delivered"
                      items.delivered
                    when "skipped"
                      items.skipped
                    when "not_skipped"
                      items.not_skipped
                    when "error"
                      items.error
                    when "scheduled"
                      items.scheduled
                    when "processed"
                      items.processed
                    else
                      items
                    end

            items.ordered
          end
        end

        private

        def set_resource
          MailyHerald::Log
        end

        def root
          "logs"
        end

        def mailing_id_present?
          params[:mailing_id].present?
        end

        def entity_id_and_type_present?
          params[:entity_id].present? && params[:entity_type].present?
        end

        def load_mailing
          @mailing = MailyHerald::Dispatch.find params[:mailing_id]
        end

        def load_entity
          @entity = params[:entity_type].classify.constantize.find params[:entity_id]
        rescue NameError
          raise ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
