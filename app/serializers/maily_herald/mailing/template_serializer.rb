module MailyHerald
  class Mailing
    class TemplateSerializer < ActiveModel::Serializer
      attributes :html, :plain

      def html
        object.html
      end

      def plain
        object.plain
      end
    end
  end
end
