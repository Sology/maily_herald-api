module MailyHerald
  module Api
    module V1
      class AdHocMailingsController < MailingsController

        private

        def mark_required
          "ad_hoc_mailing"
        end
      end
    end
  end
end
