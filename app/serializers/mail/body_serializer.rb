module Mail
  class BodySerializer < ActiveModel::Serializer
    attributes :charset, :encoding, :rawSource

    def charset
      object.charset
    end

    def encoding
      object.encoding
    end

    def rawSource
      object.raw_source
    end
  end
end
