require 'maily_herald/api/version'
require 'active_model_serializers'

if defined?(::Rails::Engine)
  require "maily_herald/api/engine"
end

module MailyHerald
  module Api
    autoload :ErrorMapper, 'maily_herald/api/error_mapper'
  end
end
