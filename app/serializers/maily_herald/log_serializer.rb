module MailyHerald
  class LogSerializer < ActiveModel::Serializer
    attributes :id, :mailingId, :entityId, :entityType, :entityEmail, :status, :data, :processingAt

    def mailingId
      object.mailing_id
    end

    def entityId
      object.entity_id
    end

    def entityType
      object.entity_type
    end

    def entityEmail
      object.entity_email
    end

    def processingAt
      object.processing_at
    end
  end
end
