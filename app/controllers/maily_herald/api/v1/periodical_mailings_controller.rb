module MailyHerald
  module Api
    module V1
      class PeriodicalMailingsController < MailingsController

        private

        def item_params
          params.require(:periodical_mailing).permit(:kind, :title, :mailer_name, :list, :from, :conditions, :subject, :template_plain, :template_html, :start_at, :period)
        end
      end
    end
  end
end
