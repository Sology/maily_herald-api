module MailyHerald
  module Api
    module V1
      class ResourcesController < BaseController
        before_action :load_resource, except: :create

        def show
          render_api @item, root: root
        end

        def create
          @item = resource.new
          assign_attributes_and_render_response
        end

        def update
          assign_attributes_and_render_response
        end

        protected

        def resource
          @resource ||= set_resource
        end

        private

        def load_resource
          @item = resource.find params[:id]
        end

        def assign_attributes_and_render_response
          @item.attributes = item_params

          if @item.save
            render_api @item, root: root
          else
            render_error @item
          end
        end
      end
    end
  end
end
