module Mail
  class HeaderSerializer < ActiveModel::Serializer
    attributes :name, :value

    def name
      object.name
    end

    def value
      object.value
    end
  end
end
