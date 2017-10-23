module MailyHerald
  class MailingSerializer < ActiveModel::Serializer
    attributes :id, :listId, :name, :title, :subject, :template, :conditions, :from, :state, :mailerName

    def listId
      object.list_id
    end

    def mailerName
      object.mailer_name
    end
  end
end
