module Mail
  class MessageSerializer < ActiveModel::Serializer
    attributes :messageId, :date, :headers
    attribute  :parts, if: :any_parts?
    attribute  :body,  if: :empty_parts?

    def messageId
      object.message_id
    end

    def date
      object.date
    end

    def parts
      object.parts.each_with_object([]) do |part, arr|
        arr << Mail::PartSerializer.new(part).as_json
        arr
      end
    end

    def headers
      get_headers.each_with_object([]) do |h, arr|
        arr << Mail::HeaderSerializer.new(h).as_json unless h.name == "Content-Type" && any_parts?
        arr
      end
    end

    def body
      Mail::BodySerializer.new(object.body).as_json
    end

    def any_parts?
      object.parts.any?
    end

    def empty_parts?
      object.parts.empty?
    end

    private

    def get_headers
      object.header.to_a.sort_by &:field_order_id
    end
  end
end
