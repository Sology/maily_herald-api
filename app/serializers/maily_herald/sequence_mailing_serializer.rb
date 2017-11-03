module MailyHerald
  class SequenceMailingSerializer < ActiveModel::Serializer
    attributes :id, :sequenceId, :kind, :name, :title, :subject, :template, :conditions, :from, :state, :mailerName, :locked, :absoluteDelay

    def sequenceId
      object.sequence_id
    end

    def template
      MailyHerald::Mailing::TemplateSerializer.new(object.template).as_json
    end

    def mailerName
      object.mailer_name
    end

    def locked
      object.locked?
    end

    def absoluteDelay
      object.absolute_delay
    end
  end
end
