module MailyHerald
  module Api
    module V1
      class OneTimeMailingsController < MailingsController

        private

        def item_params
          params.require(:one_time_mailing).permit(:title, :mailer_name, :list, :from, :conditions, :subject, :template, :start_at)
        end
      end
    end
  end
end
