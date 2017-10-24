module MailyHerald
  class OneTimeMailingSerializer < MailingSerializer
    attributes :startAt

    def startAt
      object.start_at
    end
  end
end
