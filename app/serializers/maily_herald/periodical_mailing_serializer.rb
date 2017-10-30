module MailyHerald
  class PeriodicalMailingSerializer < MailingSerializer
    attributes :startAt, :period

    def startAt
      object.start_at
    end
  end
end
