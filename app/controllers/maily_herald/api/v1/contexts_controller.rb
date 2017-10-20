module MailyHerald
  module Api
    module V1
      class ContextsController < BaseController
        before_action :load_context, only: :show

        def index
          @contexts = MailyHerald.contexts
          outcome = []
          @contexts.each {|c| outcome << build_serialized_context(c[1])} if @contexts.any?

          render_api({contexts: outcome})
        end

        def show
          raise ActiveRecord::RecordNotFound unless @context
          render_api({context: build_serialized_context(@context)})
        end

        private

        def load_context
          @context = MailyHerald.context params[:context_name]
        end

        def get_attr_keys h
          h.each_with_object([]) do |(k,v), attrs|
            attrs << k
            attrs.concat(get_attr_keys(v)) if v.is_a? Hash
          end
        end

        def attributes_for context
          context.attributes_list[context.model.to_s.downcase]
        end

        def build_serialized_context context
          {
            name: context.name,
            title: context.title,
            modelName: context.model.to_s,
            attributes: get_attr_keys(attributes_for(context))
          }
        end
      end
    end
  end
end
