module MailyHerald
  module Api
    module V1
      class OneTimeMailingsController < MailingsController

        private

        def item_params
          params.require(:one_time_mailing).permit(:kind, :title, :mailer_name, :list, :from, :conditions, :subject, :template_plain, :template_html, :start_at, :track)
        end
      end
    end
  end
end
