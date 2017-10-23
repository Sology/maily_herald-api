module MailyHerald
  module Api
    module V1
      class MailingsController < DispatchesController

        private

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
