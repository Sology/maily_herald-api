module MailyHerald
  class ListSerializer < ActiveModel::Serializer
    attributes :id, :name, :title, :contextName, :locked, :subscribersCount, :optOutsCount, :potentialSubscribersCount

    def contextName
      object.context_name
    end

    def locked
      object.locked?
    end

    def subscribersCount
      object.active_subscription_count
    end

    def optOutsCount
      object.opt_outs_count
    end

    def potentialSubscribersCount
      object.potential_subscribers_count
    end
  end
end
