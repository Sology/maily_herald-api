module MailyHerald
  class PeriodicalMailingSerializer < MailingSerializer
    attributes :startAt, :periodInDays

    def startAt
      object.start_at
    end

    def periodInDays
      object.period_in_days
    end
  end
end
