module MailyHerald
  class SequenceMailingSerializer < ActiveModel::Serializer
    attributes :id, :sequenceId, :name, :title, :subject, :template, :conditions, :from, :state, :mailerName, :locked, :absoluteDelayInDays

    def sequenceId
      object.sequence_id
    end

    def mailerName
      object.mailer_name
    end

    def locked
      object.locked?
    end

    def absoluteDelayInDays
      object.absolute_delay_in_days
    end
  end
end
