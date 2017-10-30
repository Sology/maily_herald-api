module MailyHerald
  class SequenceMailingSerializer < ActiveModel::Serializer
    attributes :id, :sequenceId, :name, :title, :subject, :template, :conditions, :from, :state, :mailerName, :locked, :absoluteDelay

    def sequenceId
      object.sequence_id
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
