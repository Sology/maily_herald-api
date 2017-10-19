module MailyHerald
  class SubscriptionSerializer < ActiveModel::Serializer
    attributes :id, :entityId, :listId, :active, :unsubscribeUrl, :settings, :data

    def entityId
      object.entity_id
    end

    def listId
      object.list_id
    end

    def unsubscribeUrl
      begin
        object.try(:token_url)
      rescue
        # Returning nil if 'host' or 'from' was not specified in environment's config.
        nil
      end
    end
  end
end
