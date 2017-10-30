module MailyHerald
  module Api
    class ErrorMapper
      attr_reader :object

      # Class instance used to get mapped errors for ActiveRecord objects.
      #
      # @param object [ActiveRecord::Base]
      def initialize object
        @object = object
      end

      # Get hash of mapped errors of object.
      def errors
        object.errors.details.inject({}) do |hash, e|
          attribute = e[0].to_s.camelize(:lower)
          error_type = e[1].first[:error]

          hash[attribute] = if error_type.match(/locked/)
                              "locked"
                            elsif error_type.match(/Liquid\ syntax\ error/)
                              "syntaxError"
                            elsif error_type.match(/is\ not\ a\ boolean\ value/)
                              "notBoolean"
                            elsif error_type.match(/is\ not\ a\ time\ value/)
                              "notTime"
                            elsif error_type.match(/greater_than/)
                              "greaterThan#{e[1].first[:value]}"
                            elsif error_type.match(/not_a_number/)
                              "notANumber"
                            else
                              error_type
                            end
          hash
        end
      end
    end
  end
end
