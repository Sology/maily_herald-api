module MailyHerald
  module Api
    module V1
      class BaseController < ActionController::Base
        protect_from_forgery with: :exception
        rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

        protected

        def render_api data, options = {}
          opts = {json: (data || {})}.merge(options)
          render(opts)
        end

        def render_error data, options = {}
          case data
          when ApplicationRecord
            data = MailyHerald::Api::ErrorMapper.new(data).errors
          when StandardError
            data = data.to_s
          end

          render_api({errors: data}, options.merge(status: 422))
        end

        def render_not_found
          render_api({error: "notFound"}, {status: 404})
        end
      end
    end
  end
end
