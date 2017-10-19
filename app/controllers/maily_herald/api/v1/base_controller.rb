module MailyHerald
  module Api
    module V1
      class BaseController < ActionController::Base
        class Paginator
          def initialize controller, data, options = {}
            @controller = controller
            @data = data
            @options = options
          end

          def page
            @page ||= params[:page].try(:to_i) || 1
          end

          def per
            @per ||= params[:per].try(:to_i) || 10
          end

          def collection
            @collection ||= @data.page(page).per(per)
          end

          def meta
            {
              page: page,
              nextPage: !!collection.next_page,
            }
          end

          private

          attr_reader :controller

          delegate :params, to: :controller
        end

        protect_from_forgery with: :exception
        rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

        protected

        def render_api data, options = {}
          paginate = options.delete(:paginate)

          opts = {json: (data || {})}.merge(options)

          if paginate
            paginator = Paginator.new(self, data)

            opts.deep_merge!(
             json: paginator.collection,
              meta: {
                pagination: paginator.meta
              }
            )
          end

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
