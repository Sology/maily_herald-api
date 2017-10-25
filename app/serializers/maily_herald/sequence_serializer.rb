module MailyHerald
  class SequenceSerializer < ActiveModel::Serializer
    attributes :id, :listId, :name, :title, :state, :startAt, :locked
    has_many :mailings, key: :sequenceMailings, serializer: MailyHerald::SequenceMailingSerializer

    def listId
      object.list_id
    end

    def startAt
      object.start_at
    end

    def locked
      object.locked?
    end
  end
end
