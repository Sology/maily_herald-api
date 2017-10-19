module MailyHerald
  module Api
    module V1
      class ContextsController < BaseController
        before_action :load_context

        def show
          raise ActiveRecord::RecordNotFound unless @context

          render_api({
            context: {
              name: @context.name,
              title: @context.title,
              modelName: @context.model.to_s,
              attributes: get_attrs(context_attributes)
            }
          })
        end

        private

        def load_context
          @context = MailyHerald.context params[:context_name]
        end

        def get_attrs h
          h.each_with_object([]) do |(k,v), attrs|      
            attrs << k
            attrs.concat(get_attrs(v)) if v.is_a? Hash
          end
        end

        def context_attributes
          @context.attributes_list[@context.model.to_s.downcase]
        end
      end
    end
  end
end
