module MailyHerald
  class MailingSerializer < ActiveModel::Serializer
    attributes :id, :listId, :kind, :name, :title, :subject, :template, :conditions, :from, :state, :mailerName, :locked

    def listId
      object.list_id
    end

    def mailerName
      object.mailer_name
    end

    def locked
      object.locked?
    end

    def template
      MailyHerald::Mailing::TemplateSerializer.new(object.template_wrapper).as_json
    end
  end
end
