module MailyHerald
  class ListSerializer < ActiveModel::Serializer
    attributes :id, :name, :title, :context_name, :locked

    def locked
      object.locked?
    end
  end
end
