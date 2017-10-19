module MailyHerald
  class SubscriptionSerializer < ActiveModel::Serializer
    attributes :id, :entity_id, :list_id, :active, :unsubscribe_url, :settings, :data

    def unsubscribe_url
      begin
        object.try(:token_url)
      rescue
        nil
      end
    end
  end
end
