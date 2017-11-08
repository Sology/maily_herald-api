module Mail
  class PartSerializer < ActiveModel::Serializer
    attributes :headers, :body

    def headers
      get_headers.each_with_object([]) do |h, arr|
        arr << Mail::HeaderSerializer.new(h).as_json
        arr
      end
    end

    def body
      Mail::BodySerializer.new(object.body).as_json
    end

    private

    def get_headers
      object.header.to_a.sort_by &:field_order_id
    end
  end
end
