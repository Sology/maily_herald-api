module MailyHerald
  module Api
    module V1
      class PeriodicalMailingsController < MailingsController

        private

        def item_params
          params.require(:periodical_mailing).permit(:title, :mailer_name, :list, :from, :conditions, :subject, :template, :start_at, :period_in_days)
        end
      end
    end
  end
end
